json.extract! registrar_feed, :id, :status, :approved_etds, :graduated_etds, :published_etds, :created_at, :updated_at
json.url registrar_feed_url(registrar_feed, format: :json)
