require 'fileutils'
require 'loofah'
require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'zip'
require 'zip/filesystem'

module ProquestBehaviors
  attr_accessor :registrar_data
  attr_accessor :export_directory

  # Export a zipped directory of an ETD in the format expected by ProQuest
  def export_zipped_proquest_package
    FileUtils.mkdir_p Rails.configuration.proquest_export_directory
    output_file = Rails.configuration.proquest_export_directory.join("#{export_id}.zip").to_s
    Zip::File.open(output_file, Zip::File::CREATE) do |zip|
      zip.dir.mkdir(export_id)
      zip.file.open("#{export_id}/#{export_id}.xml", 'w') { |file| file.write(export_proquest_xml) }
      members.each do |fs|
        zip.file.open("#{export_id}/#{fs.label}", "wb") do |saved_file|
          open(fs.files.first.uri, "rb") do |read_file|
            saved_file.write(read_file.read)
          end
        end
      end
    end
    Rails.logger.info "ProQuest package created: #{output_file}"
  end

  # Given a ppid, load the configured JSON file of registrar data, return the portion
  # relevant to the user in question
  # @param [String] ppid
  # @return [Hash]
  def load_registrar_data_for_user(ppid)
    ppid = "P0000001" if Rails.env.development? # Otherwise it will never find registrar data for our fake users
    registrar_hash = JSON.parse(File.read(Rails.configuration.registrar_data))
    @registrar_data = registrar_hash.select { |p| p.match(ppid) }.values.first
    return @registrar_data if @registrar_data
    Rails.logger.error "FAILURE TO EXPORT PROQUEST PACKAGE: Cannot find registrar data for user #{ppid} etd #{id}"
    raise "Cannot find registrar data for user #{ppid} etd #{id}"
  end

  def registrar_data
    @registrar_data ||= load_registrar_data_for_user(depositor)
  end

  def export_directory
    @export_directory ||= make_export_directory
  end

  def export_id
    creator.first.downcase.tr(',', '_').tr(' ', '').strip + '_' + id
  end

  def make_export_directory
    dirname = Rails.configuration.proquest_export_directory.join(export_id)
    FileUtils.mkdir_p dirname
    dirname
  end

  def proquest_language
    return "EN" if language.first == "English"
    return "FR" if language.first == "French"
    return "SP" if language.first == "Spanish"
  end

  def proquest_submission_type
    return "masters" if submitting_type.first == "Master's Thesis"
    return "doctoral" if submitting_type.first == "Dissertation"
  end

  def page_count
    primary_pdf_fs = members.select { |a| a.pcdm_use == "primary" }.first
    primary_pdf_fs.files.first.metadata.attributes["http://www.semanticdesktop.org/ontologies/2007/03/22/nfo#pageCount"].first
  rescue
    "unknown"
  end

  def proquest_diss_accept_date
    degree_awarded.strftime("%d/%m/%Y")
  end

  def proquest_diss_comp_date
    degree_awarded.strftime("%Y")
  end

  def proquest_code(field_name)
    research_fields_yml = Rails.root.join("config", "authorities", "research_fields.yml")
    research_fields_hash = YAML.safe_load(File.read(research_fields_yml))
    research_fields_hash["terms"].select { |a| a["id"] == field_name }.first["term"]
  end

  def primary_pdf_file_name
    primary_pdf_fs = members.select { |a| a.pcdm_use == "primary" }.first
    primary_pdf_fs.label
  end

  # Given text output from tinymce, turn it into something ProQuest can handle
  # @param [String] tinymce_output
  # @return [String] proquest sanitized text
  def mce_to_proquest(tinymce_output)
    clean_html = Sanitize.clean(tinymce_output, elements: ['p', 'em', 'b', 'i'])

    proquest_scrubber = Loofah::Scrubber.new do |node|
      if node.name == "img" || node.name == "br"
        node.remove
        Loofah::Scrubber::STOP # don't bother with the rest of the subtree
      end
      node.name = "DISS_para" if node.name == "p"
      node.name = "italic" if node.name == "em"
      node.name = "italic" if node.name == "b"
      node.name = "italic" if node.name == "i"
    end
    doc = Loofah.fragment(clean_html).scrub!(:whitewash).scrub!(proquest_scrubber)
    CGI.unescapeHTML(doc.to_s)
  end

  def export_proquest_xml
    @registrar_data = registrar_data
    lastname, firstname = creator.first.split(", ")
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.DISS_submission {
        xml.DISS_authorship {
          xml.DISS_author(type: 'primary') {
            xml.DISS_name {
              xml.DISS_surname lastname
              xml.DISS_fname firstname
              xml.DISS_affiliation department.first
            }
            xml.DISS_contact(type: "future") {
              xml.DISS_contact_effdt Time.zone.today.strftime('%m/%d/%Y')
              xml.DISS_address {
                xml.DISS_addrline "#{@registrar_data['home address 1']} #{@registrar_data['home address 2']} #{@registrar_data['home address 3']}".strip!
                xml.DISS_city @registrar_data["home address city"]
                xml.DISS_st @registrar_data["home address state"]
                xml.DISS_pcode @registrar_data["home address postal code"]
                xml.DISS_country @registrar_data["home address country descr"]
              }
              xml.DISS_email post_graduation_email.first
            }
          }
        }
        xml.DISS_description(external_id: id, page_count: page_count, type: proquest_submission_type, apply_for_copyright: "no") {
          xml.DISS_title title.first
          xml.DISS_dates {
            xml.DISS_comp_date proquest_diss_comp_date
            xml.DISS_accept_date proquest_diss_accept_date
          }
          xml.DISS_degree "Ph.D."
          xml.DISS_institution {
            xml.DISS_inst_code "0665"
            xml.DISS_inst_name "Emory University"
            xml.DISS_inst_contact department.first
          }
          xml.DISS_advisor {
            xml.DISS_name {
              xml.DISS_surname committee_chair.first.last_name
              xml.DISS_fname committee_chair.first.first_name
              xml.DISS_affiliation committee_chair.first.affiliation.first
            }
          }
          committee_members.each do |committee_member|
            xml.DISS_cmte_member {
              xml.DISS_name {
                xml.DISS_surname committee_member.last_name
                xml.DISS_fname committee_member.first_name
                xml.DISS_affiliation committee_member.affiliation.first
              }
            }
          end
          xml.DISS_categorization {
            research_field.each do |field_name|
              xml.DISS_category {
                xml.DISS_cat_code proquest_code(field_name)
                xml.DISS_cat_desc field_name
              }
            end
            keyword.each do |k|
              xml.DISS_keyword k
            end
            xml.DISS_ISBN
            xml.DISS_language proquest_language
          }
        }
        xml.DISS_content {
          xml.DISS_abstract mce_to_proquest(abstract.first)
          xml.DISS_binary(primary_pdf_file_name, type: "PDF")
          members.select { |a| a.pcdm_use == "supplementary" }.each do |attachment|
            xml.DISS_attachment {
              xml.DISS_file_name attachment.label
              xml.DISS_file_category attachment.file_type
              xml.DISS_file_descr attachment.description.first
            }
          end
        }
      }
    end
    CGI.unescapeHTML(builder.to_xml)
  end
end
