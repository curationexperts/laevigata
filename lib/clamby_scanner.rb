class ClambyScanner < Hydra::Works::VirusScanner
  def infected?
    false
    # Clamby.virus?(file)
  end
end
