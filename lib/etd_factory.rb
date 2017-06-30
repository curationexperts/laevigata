require File.expand_path('../../config/environment', __FILE__)
require 'yaml'

# Build an ETD from passed in data, including attaching all files and kicking off their background jobs
class EtdFactory
  attr_accessor :etd
  attr_accessor :primary_pdf_file

  def assign_admin_set
    return unless etd
    etd.admin_set = ::AdminSet.where(title: etd.school.first).first
    etd.save
  end

  def attach_primary_pdf_file
    uf = Hyrax::UploadedFile.create(file: File.open(primary_pdf_file))
    AttachFilesToWorkJob.perform_now(etd, [uf])
    primary_file_set = etd.ordered_members.to_a.first
    primary_file_set.embargo = etd.embargo
    primary_file_set.primary = true
    primary_file_set.save
  end
end
