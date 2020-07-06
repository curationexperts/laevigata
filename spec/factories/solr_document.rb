FactoryBot.define do
  factory :solr_document do
    factory :etd_to_solr do
      {
        "system_create_dtsi" => "2020-07-06T21:37:48Z",
        "system_modified_dtsi" => "2020-07-06T21:37:48Z",
        "has_model_ssim" => ["Etd"],
        :id => "g158bh38x",
        "title_tesim" => ["Legend of Blue Imp"],
        "title_sim" => ["Legend of Blue Imp"],
        "files_embargoed_bsi" => false,
        "files_embargoed_sim" => [false],
        "abstract_embargoed_bsi" => false,
        "abstract_embargoed_sim" => [false],
        "toc_embargoed_bsi" => false,
        "toc_embargoed_sim" => [false],
        "rights_statement_tesim" => ["Permission granted by the author to include this thesis or dissertation in this repository. All rights reserved by the author. Please contact the author for information regarding the reproduction and use of this thesis or dissertation."],
        "hidden?_bsi" => false,
        "thumbnail_path_ss" => "/assets/work-ff055336041c3f7d310ad69109eda4a887b16ec501f35afc0a547c4adb97ee72.png",
        "suppressed_bsi" => false,
        "member_ids_ssim" => [],
        "member_of_collections_ssim" => [],
        "member_of_collection_ids_ssim" => [],
        "generic_type_sim" => ["Work"],
        "file_set_ids_ssim" => [],
        "visibility_ssi" => "open",
        "admin_set_sim" => "",
        "admin_set_tesim" => "",
        "committee_names_sim" => [],
        "human_readable_type_sim" => "ETD",
        "human_readable_type_tesim" => "ETD",
        "read_access_group_ssim" => ["public"]
      }
    end
  end
end
