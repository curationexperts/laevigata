FactoryBot.define do
  registrar_sample_json = Rack::Test::UploadedFile.new(
    Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'registrar_sample.json'), 'application/json'
  )
  registrar_sample_csv = Rack::Test::UploadedFile.new(
    Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'registrar_sample.csv'), 'text/csv'
  )
  sample_report = Rack::Test::UploadedFile.new(
    Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'graduation_report.csv'), 'text/csv'
  )

  factory :registrar_feed do
    graduation_records { registrar_sample_csv }
    approved_etds { 1 }
    graduated_etds { 0 }
    published_etds { 2 }

    factory :json_registrar_feed do
      graduation_records { registrar_sample_json }
    end

    factory :completed_registrar_feed do
      report { sample_report }
      status { 'completed' }
    end
  end
end
