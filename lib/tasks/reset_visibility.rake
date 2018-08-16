namespace :emory do
  desc "Set visibility to public for unembargoed, unhidden ETDs and their members."
  task :reset_visibility do
    open = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    puts 'Resetting Etd and FileSet visiblities to "open"'

    Etd.all.each do |etd|
      if etd.hidden? || etd.under_embargo?
        puts "Skipping #{etd.id}"
        next
      end

      etd.file_sets.each do |file_set|
        next if file_set.visibility == open
        file_set.visibility = open
        file_set.save!
      end

      next if etd.visibility == open
      etd.visibility = open
      etd.save!

      puts "Etd #{etd.id} set to #{open}"
    end
  end
end
