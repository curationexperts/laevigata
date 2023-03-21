class TestVirusScanner < Hydra::Works::VirusScanner
  def self.infected?(_file)
    false
  end
end
