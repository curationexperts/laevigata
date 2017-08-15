module EtdHelper
  def school_determined_departments(f)
    # if you are in a 'new' state, collection will be supplied by js so disable field, nothing selected
    if curation_concern.id.nil?
      f.input :department, as: :select, include_blank: true, input_html: {
        class: 'form-control',
        'data-option-dependent' => true,
        'data-option-observed' => 'etd_school',
        'data-option-url' => '/authorities/terms/local/:etd_school:',
        'data-option-key-method' => :id,
        'data-option-value-method' => :name, disabled: true
      }, label: 'Department'
    else
      # if you are in an 'edit' state
      f.input :department, as: :select, collection: departments(curation_concern[:school].first), selected: curation_concern[:department].first, include_blank: true, input_html: {
        class: 'form-control',
        'data-option-dependent' => true,
        'data-option-observed' => 'etd_school',
        'data-option-url' => '/authorities/terms/local/:etd_school:',
        'data-option-key-method' => :id,
        'data-option-value-method' => :name, disabled: false
      }, label: 'Department'
    end
  end

  def department_determined_subfields(f)
    # a 'new' state, nothing is selected and disable subfields
    if curation_concern.id.nil?
      f.input :subfield, as: :select, include_blank: true, input_html: {
        class: 'form-control',
        "data-option-dependent" => true,
        "data-option-observed" => "etd_department",
        "data-option-url" => "/authorities/terms/local/:etd_department:",
        "data-option-key-method" => :id,
        "data-option-value-method" => :name,
        disabled: true
      }, label: "Sub Field"
    # either new or department without subfields,
    # in either case collection will be supplied by js, disable fields and nothing selected
    elsif curation_concern['subfield'].empty?
      f.input :subfield, as: :select, include_blank: true, input_html: {
        class: 'form-control',
        "data-option-dependent" => true,
        "data-option-observed" => "etd_department",
        "data-option-url" => "/authorities/terms/local/:etd_department:",
        "data-option-key-method" => :id,
        "data-option-value-method" => :name,
        disabled: true
      }, label: "Sub Field"
    else
      f.input :subfield, as: :select, collection: subfields(curation_concern[:department].first), selected: curation_concern[:subfield].first, include_blank: true, input_html: {
        class: 'form-control',
        "data-option-dependent" => true,
        "data-option-observed" => "etd_department",
        "data-option-url" => "/authorities/terms/local/:etd_department:",
        "data-option-key-method" => :id,
        "data-option-value-method" => :name,
        disabled: false
      }, label: "Sub Field"
    end
  end

    private

      def departments(school)
        return unless school
        if school.include? 'Emory'
          Hyrax::EmoryService.new.select_all_options
        elsif school.include? 'Laney'
          Hyrax::LaneyService.new.select_all_options
        elsif school.include? 'Candler'
          Hyrax::CandlerService.new.select_all_options
        elsif school.include? 'Rollins'
          Hyrax::RollinsService.new.select_all_options
        else
          ''
        end
      end

      def subfields(department)
        if department == 'Biology'
          Hyrax::BiomedService.new.select_all_options
        elsif department == 'Psychology'
          Hyrax::PsychologyService.new.select_all_options
        elsif department.include? 'Religion'
          Hyrax::ReligionService.new.select_all_options
        else
          ''
        end
      end
end
