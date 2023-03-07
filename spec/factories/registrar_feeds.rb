FactoryBot.define do
  factory :registrar_feed do
    status { 1 }
    approved_etds { 1 }
    graduated_etds { 1 }
    published_etds { 1 }
  end
end
