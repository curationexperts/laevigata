namespace :emory do
  desc "Enforce FileSet embagro for embargoed Etds."
  task :embargo_enforcement do
    Hyrax::EmbargoService.assets_under_embargo.each do |presenter|
      etd = presenter.model_name.name.constantize.find(presenter.id)
      next unless etd.is_a? Etd

      etd.file_sets.each do |fs|
        fs.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        fs.save
      end
    end
  end
end
