module Hyrax
  module Actors
    class EtdActor < Hyrax::Actors::BaseActor
      KNOWN_NESTED_ATTRIBUTES = [:committee_members_attributes,
                                 :committee_chair_attributes].freeze

      private

        def apply_save_data_to_curation_concern(env)
          translate_embargo_types(env)
          super
          # ActiveFedora fails to propgate changes to nested attributes to
          # `#resource` when indexed nested attributes are used. We force the
          # issue here to work around for form edits.
          (env.attributes.keys && KNOWN_NESTED_ATTRIBUTES).each do |attribute_key|
            attribute = attribute_key.to_s.gsub('_attributes', '').to_sym
            env.curation_concern.send(attribute).each { |member| member.try(:persist!) }
          end
        end

        # We must translate a value like env.attributes[:embargo_type] = "all_restricted"
        # into the ETD's expected etd.files_embargoed = 'true', etd.toc_embargoed = 'true',
        # etd.abstract_embargoed = 'true'
        def translate_embargo_types(env)
          return unless env.attributes[:embargo_type]
          embargo_type = env.attributes.delete(:embargo_type)
          env.attributes[:files_embargoed]    = files_included?(embargo_type)
          env.attributes[:toc_embargoed]      = toc_included?(embargo_type)
          env.attributes[:abstract_embargoed] = abstract_included?(embargo_type)
        end

      def files_included?(embargo_type)
        embargo_type.match?(VisibilityTranslator::FILES_EMBARGOED) ||
          embargo_type.match?(VisibilityTranslator::TOC_EMBARGOED) ||
          embargo_type.match?(VisibilityTranslator::ALL_EMBARGOED)
      end

      def toc_included?(embargo_type)
        embargo_type.match?(VisibilityTranslator::TOC_EMBARGOED) ||
          embargo_type.match?(VisibilityTranslator::ALL_EMBARGOED)
      end

      def abstract_included?(embargo_type)
        embargo_type.match?(VisibilityTranslator::ALL_EMBARGOED)
      end
    end
  end
end
