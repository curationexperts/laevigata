require 'nokogiri'
module ProquestBehaviors
  attr_accessor :path_to_registrar_data
  # Given a ppid and a JSON file of registrar data, return the portion of the
  # registrar data relevant to the user in question
  # @param [String] ppid
  # @param [String] path_to_registrar_data
  # @return [Hash]
  def load_registrar_data_for_user(ppid, path_to_registrar_data = @path_to_registrar_data)
    registrar_hash = JSON.parse(File.read(path_to_registrar_data))
    @registrar_data = registrar_hash.select { |p| p.match(ppid) }.values.first
    @registrar_data
  end

  def registrar_data
    @registrar_data ||= load_registrar_data_for_user(depositor, @path_to_registrar_data)
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
          xml.DISS_degree degree.first
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
          # TODO: Format as ProQuest expects, with paragraph tags and translated emphasis tags
          xml.DISS_abstract {
            xml.DISS_para abstract.first
          }
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
    builder.to_xml
  end
end
