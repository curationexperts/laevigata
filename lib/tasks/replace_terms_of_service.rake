namespace :emory do
  desc "Replace the Terms of Use ContentBlock with what's in version control"
  task :terms_of_service do
    file = File.open("/opt/laevigata/current/app/views/hyrax/content_blocks/terms.html.erb")
    tou = file.read
    cb = ContentBlock.where(name: 'terms_page').first
    cb.value = tou
    cb.save
    file.close
  end
end
