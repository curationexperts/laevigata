module Importer
  class MigrationMapper < Darlingtonia::MetadataMapper
    EXPORT_REQUEST =
      '/export?format=info:fedora/fedora-system:FOXML-1.1&context=archive'.freeze

    NAMESPACES = {
      etd:   'http://www.ndltd.org/standards/metadata/etdms/1.0/',
      foxml: 'info:fedora/fedora-system:def/foxml#',
      mads:  'http://www.loc.gov/mads/',
      mods:  'http://www.loc.gov/mods/v3',
      rdf:   'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      rel:   'info:fedora/fedora-system:def/relations-external#'
    }.freeze

    SCHOOL_TERMS = {
      "info:fedora/emory-control:ETD-Candler-collection"    => 'Candler School of Theology',
      "info:fedora/emory-control:ETD-GradSchool-collection" => 'Laney Graduate School',
      "info:fedora/emory-control:ETD-College-collection"    => 'Emory College',
      "info:fedora/emory-control:ETD-Rollins-collection"    => 'Rollins School of Public Health'
    }.freeze

    ##
    # @!attribute [rw] source_host
    #   @return [String]
    attr_accessor :source_host

    ##
    # @param source_host [String]
    def initialize(source_host: nil)
      self.source_host = source_host
    end

    ##
    # @return [String] the source record's Fedora 3 pid
    def pid
      metadata
    end

    def fields
      [:pid, :title, :embargo_lift_date, :abstract, :committee_chair_attributes,
       :committee_members_attributes, :creator, :degree, :degree_awarded,
       :degree_granting_institution, :department, :email, :legacy_id,
       :graduation_year, :keyword, :partnering_agency, :post_graduation_email,
       :research_field, :research_field_id, :school, :subfield,
       :submitting_type, :table_of_contents, :abstract_embargoed,
       :files_embargoed, :toc_embargoed]
    end

    def supplementary_files
      return enum_for(:supplementary_files) unless block_given?

      repository_object.supplementary_files.each do |file|
        yield BinaryFile.new(file)
      end
    end

    def primary_file
      BinaryFile.new(repository_object.pdf_file)
    end

    def embargo_lift_date
      date_str =
        mods_node
          .xpath('./mods:originInfo/mods:dateOther[@type = "embargoedUntil"]', NAMESPACES)
          .first&.content

      date_str.present? && Date.parse(date_str)
    rescue StandardError => e
      raise(MappingError, e)
    end

    def abstract_embargoed
      mods_node
        .xpath('./mods:note[@ID="embargo"]', NAMESPACES)
        .any? { |node| node.content.downcase.include? 'abstract' }
    end

    def files_embargoed
      mods_node
        .xpath('./mods:note[@ID="embargo"]', NAMESPACES)
        .any? { |node| node.content.downcase.include? 'file' }
    end

    def toc_embargoed
      mods_node
        .xpath('./mods:note[@ID="embargo"]', NAMESPACES)
        .any? { |node| node.content.downcase.include? 'toc' }
    end

    def title
      mods_node
        .xpath('./mods:titleInfo/mods:title', NAMESPACES)
        .map(&:content)
    end

    def abstract
      abstract_string = repository_object
                          .xhtml.as_xml
                          .xpath('./html/div[@id="abstract"]')
                          .children.to_s
      Array.wrap(HtmlSanitizer.sanitize(abstract_string))
    end

    def committee_chair_attributes
      count = 0

      committee_chair_nodes.each_with_object({}) do |member, attrs|
        attrs[count] = {}
        attrs[count][:netid]       = [member.attribute('ID')&.value].compact
        attrs[count][:affiliation] = member.xpath('./mods:affiliation').map(&:content)
        attrs[count][:name]        = member.xpath('./mods:displayForm')
                                       .map(&:content).reject { |name| name == ', ' }
        count += 1
      end
    end

    def committee_members_attributes
      count = 0

      committee_member_nodes.each_with_object({}) do |member, attrs|
        attrs[count] = {}
        attrs[count][:netid]       = [member.attribute('ID')&.value].compact
        attrs[count][:affiliation] = member.xpath('./mods:affiliation').map(&:content)
        attrs[count][:name]        = member.xpath('./mods:displayForm')
                                       .map(&:content).reject { |name| name == ', ' }
        count += 1
      end
    end

    def creator
      mods_author_node.xpath('./mods:displayForm', NAMESPACES).map(&:content)
    end

    def degree
      mods_node
        .xpath('./mods:extension/etd:degree/etd:name', NAMESPACES)
        .map(&:content)
    end

    def degree_awarded
      date_str = mods_node.xpath('./mods:originInfo/mods:dateIssued', NAMESPACES).first&.content

      date_str.present? && Date.parse(date_str)
    rescue StandardError => e
      raise(MappingError, e)
    end

    def degree_granting_institution
      'http://id.loc.gov/vocabulary/organizations/geu'
    end

    def department
      mods_author_node.xpath('./mods:affiliation').map(&:content)
    end

    def email
      author_info_mads_node
        .xpath('./mads:affiliation/mads:position[text()="permanent resident"]/ancestor-or-self::mads:affiliation/mads:email', NAMESPACES)
        .map(&:content)
    end

    def graduation_year
      date_str =
        mods_node
          .xpath('./mods:originInfo/mods:dateIssued', NAMESPACES).first
          .content.split('-').first
      date_str unless date_str.nil? || date_str.empty?
    end

    def keyword
      mods_node
        .xpath('./mods:subject[@authority="keyword"]/mods:topic', NAMESPACES)
        .map(&:content)
    end

    def legacy_id
      ids = mods_node
              .xpath('./mods:identifier[@type="ark"]')
              .map(&:content)
      ids + Array(pid)
    end

    def post_graduation_email
      email
    end

    def partnering_agency
      mods_node
        .xpath('./mods:note[@type="partneragencytype"]', NAMESPACES)
        .map(&:content)
    end

    def research_field
      research_field_authority = ResearchFieldService.new.authority

      research_field_id.map do |id|
        research_field_authority.search(id).select { |term| term['label'] == id }.first['id']
      end
    end

    def research_field_id
      mods_node
        .xpath('./mods:subject[@authority="proquestresearchfield"]', NAMESPACES)
        .map { |research_field| research_field.attributes['ID'].value.gsub('id', '') }
    end

    def rights
      mods_node
        .xpath('./mods:accessCondition[@type="useAndReproduction"]', NAMESPACES)
    end

    def school
      repository_object
        .rels.as_xml
        .xpath('.//rel:isMemberOfCollection/@rdf:resource', NAMESPACES)
        .map { |uri| SCHOOL_TERMS[uri.value] }.compact
    end

    def subfield
      mods_node
        .xpath('./mods:extension/etd:degree/etd:discipline', NAMESPACES)
        .map(&:content)
        .reject(&:empty?)
    end

    def submitting_type
      mods_node.xpath('./mods:genre', NAMESPACES).map(&:content)
    end

    def table_of_contents
      contents = repository_object
                   .xhtml.as_xml
                   .xpath('./html/div[@id="contents"]')
                   .children.to_s

      Array.wrap(HtmlSanitizer.sanitize(contents))
    end

    class RepositoryObject
      attr_accessor :pid, :source_host

      def initialize(pid:, source_host:)
        @datastreams     = {}
        self.pid         = pid
        self.source_host = source_host
      end

      def datastream(dsid:)
        @datastreams[dsid] ||=
          begin
            node = archive_foxml
                     .xpath("//foxml:datastream[@ID='#{dsid}']", NAMESPACES)
                     .first
            raise "#{dsid} does not exist." unless node
            Datastream.new(node: node)
          end
      end

      def rels
        datastream(dsid: 'RELS-EXT')
      end

      def mods
        datastream(dsid: 'MODS')
      end

      def xhtml
        datastream(dsid: 'XHTML')
      end

      def archive_foxml
        @archive_foxml ||= begin
                             response = Faraday.get(archive_path)
                             Nokogiri::XML(response.body)
                           end
      end

      def archive_path
        "#{source_host}#{pid}#{EXPORT_REQUEST}"
      end

      def pdf_file
        @pdf_file ||=
          begin
            pdf_file_id =
              rels.as_xml
                .xpath('.//rel:hasPDF', NAMESPACES).first
                .attributes['resource'].value.split('/').last

            RepositoryObject.new(pid: pdf_file_id, source_host: source_host)
          end
      end

      def original_file
        @original_file ||=
          begin
            original_file_id =
              rels.as_xml
                .xpath('.//rel:hasOriginal', NAMESPACES).first
                .attributes['resource'].value.split('/').last

            RepositoryObject.new(pid: original_file_id, source_host: source_host)
          end
      end

      def supplementary_files
        return enum_for(:supplementary_files) unless block_given?

        yield original_file if original_file

        rels.as_xml.xpath('.//rel:hasSupplement', NAMESPACES).each do |node|
          file_id = node.attributes['resource'].value.split('/').last

          yield RepositoryObject.new(pid: file_id, source_host: source_host)
        end
      end

      def author_info
        @author_info ||=
          begin
            author_info_id =
              rels.as_xml
                .xpath('.//rel:hasAuthorInfo', NAMESPACES).first
                .attributes['resource'].value.split('/').last

            RepositoryObject.new(pid: author_info_id, source_host: source_host)
          end
      end
    end

    class Datastream
      attr_accessor :datastream_node

      def initialize(node:)
        self.datastream_node = node
      end

      def current
        versions.last
      end

      def versions
        datastream_node
          .xpath('./foxml:datastreamVersion', NAMESPACES)
          .sort { |a, b| a['ID'].split('.').last.to_i <=> b['ID'].split('.').last.to_i }
      end

      def content
        @content ||=
          Base64.decode64(current.xpath('./foxml:binaryContent', NAMESPACES).first.content)
      end

      def as_xml
        @xml = Nokogiri::XML(content)
      end

      def valid?
        digest_node.attribute('TYPE').value == 'MD5' &&
          Digest::MD5.hexdigest(content) == digest_node.attribute('DIGEST').value
      end

      def digest_node
        current.xpath('./foxml:contentDigest', NAMESPACES)
      end
    end

    class BinaryFile
      attr_reader :object

      def initialize(object)
        @object = object
      end

      def name
        object
          .archive_foxml
          .xpath('./foxml:digitalObject/foxml:objectProperties/foxml:property[@NAME="info:fedora/fedora-system:def/model#label"]', NAMESPACES)
          .attribute('VALUE')
          .content
      end

      def content
        object.datastream(dsid: 'FILE').content
      end

      def to_s
        content
      end
    end

    class HtmlSanitizer
      # Remove any markup except the elements explicitly allowed here
      def self.sanitize(raw_input)
        clean_html = Sanitize.clean(
          raw_input,
          elements: [
            'b',
            'blockquote',
            'br',
            'code',
            'em',
            'i',
            'p',
            'span',
            'strong',
            'style',
            'sup'
          ],
          attributes: {
            'p' => ['style'],
            'span' => ['style']
          },
          css: {
            properties: [
              'font-family',
              'margin',
              'padding',
              'text-align',
              'text-decoration',
              'width'
            ]
          }
        )
        CGI.unescapeHTML(clean_html.to_s)
      end
    end

    class MappingError < RuntimeError
      def initialize(reason = nil)
        @reason = reason
        set_backtrace reason.backtrace if reason
      end

      def message
        @reason.message
      end
    end

    private

      def repository_object
        @repository_object ||=
          RepositoryObject.new(pid: pid, source_host: source_host)
      end

      def author_info_mads_node
        repository_object.author_info.datastream(dsid: 'MADS').as_xml.xpath('./mads:mads', NAMESPACES).first
      end

      def mods_node
        repository_object.mods.as_xml.xpath('./mods:mods', NAMESPACES).first
      end

      def mods_author_node
        mods_node
          .xpath('./mods:name/mods:role/mods:roleTerm[text()="author"]/ancestor-or-self::mods:name',
                 NAMESPACES)
      end

      def committee_chair_nodes
        mods_node
          .xpath('./mods:name/mods:role/mods:roleTerm[text()="Thesis Advisor"]/ancestor::mods:name',
                 NAMESPACES)
      end

      def committee_member_nodes
        mods_node
          .xpath('./mods:name/mods:role/mods:roleTerm[text()="Committee Member"]/ancestor::mods:name',
                 NAMESPACES)
      end
  end
end
