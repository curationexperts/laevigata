FactoryBot.define do
  registrar_sample = Rack::Test::UploadedFile.new(
    Rails.root.join('spec', 'fixtures', 'registrar_sample.json'), 'application/json'
  )
  sample_report = Rack::Test::UploadedFile.new(
    Rails.root.join('spec', 'fixtures', 'registrar_feeds', 'graduation_report.csv'), 'text/csv'
  )

  factory :registrar_feed do
    graduation_records { registrar_sample }
    approved_etds { 1 }
    graduated_etds { 0 }
    published_etds { 2 }

    factory :completeted_registrar_feed do
      report { sample_report }
      status { 'completed' }
    end
  end
end
