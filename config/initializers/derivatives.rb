Hydra::Derivatives::DocumentDerivatives.processor_class.timeout = 5.minutes

# Don't attempt to create derivatives for `file_set.class.office_document_mime_types`
Hyrax::FileSetDerivativesService.redefine_method(:create_office_document_derivatives) { |*_args| }
