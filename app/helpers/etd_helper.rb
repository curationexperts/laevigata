module EtdHelper
  mattr_accessor :curation_concern
  self.curation_concern = @curation_concern ||= curation_concern

  def school_determined_departments(f)
    # if you are in a 'new' state, collection will be supplied by js so disable field, nothing selected
    if @curation_concern.new_record?
      f.input :department, department_form_opts(disabled: true)
    else
      f.input :department, department_form_opts(disabled: false).merge(collection: departments(@curation_concern[:school].first), selected: @curation_concern[:department].first)
    end
  end

  def department_determined_subfields(f)
    # a 'new' state, nothing is selected and disable subfields
    if @curation_concern.new_record? || curation_concern['subfield'].empty?

      f.input :subfield, subfield_form_opts(disabled: true)

    else
      f.input :subfield, subfield_form_opts(disabled: false).merge(collection: subfields(@curation_concern[:department].first), selected: @curation_concern[:subfield].first)
    end
  end

  def partnering_agency(f)
    if @curation_concern.new_record?
      f.input :partnering_agency,
              partnering_agency_form_opts
    else
      f.input :partnering_agency, partnering_agency_form_opts.merge(
        selected: @curation_concern[:partnering_agency].first
      )
    end
  end

  def post_graduation_email(f)
    etd = Etd.find(f)
    etd.post_graduation_email.first
  end

    private

      def departments(school)
        service = Hyrax::LaevigataAuthorityService.for(school: school)

        service&.select_active_options || []
      end

      def subfields(department)
        service = Hyrax::LaevigataAuthorityService.for(department: department)
        service&.select_active_options || []
      end

      def partnering_agency_form_opts
        partnering_service = PartnersService.new
        { as: :etd_multi_value_select,
          include_blank: true, label: "Partnering Agency", collection: partnering_service.select_all_options,
          input_html: { class: 'form-control' } }
      end

      def subfield_form_opts(disabled:)
        { as: :select, include_blank: true, input_html: {
          class: 'form-control',
          "data-option-dependent" => true,
          "data-option-observed" => "etd_department",
          "data-option-url" => "/authorities/terms/local/:etd_department:",
          "data-option-key-method" => :id,
          "data-option-value-method" => :name,
          disabled: disabled
        }, label: "Sub Field" }
      end

      def department_form_opts(disabled:)
        { as: :select, include_blank: true, required: true, input_html: {
          class: 'form-control',
          'data-option-dependent' => true,
          'data-option-observed' => 'etd_school',
          'data-option-url' => '/authorities/terms/local/:etd_school:',
          'data-option-key-method' => :id,
          'data-option-value-method' => :name, disabled: disabled
        }, label: 'Department' }
      end
end
