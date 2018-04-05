BrowseEverything::Driver::Box.redefine_method(:link_for) do |id|
  file = box_client.file_by_id(id)
  download_url = file.download_url
  auth_header = { 'Authorization' => "Bearer #{@token}" }
  expiry_time = (ENV['BOX_EXPIRY_TIME_IN_MINUTES'] || 360).to_i.minutes.from_now
  extras = { auth_header: auth_header, expires: expiry_time, file_name: file.name, file_size: file.size.to_i }
  [download_url, extras]
end
