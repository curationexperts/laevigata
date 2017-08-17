class ClambyScanner < Hydra::Works::VirusScanner
  def infected?
    Clamby.virus?(file)
  end
end
