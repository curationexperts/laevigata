require File.expand_path('../../config/environment', __FILE__)
require 'yaml'

# Build an ETD from passed in data, including attaching all files and kicking off their background jobs
class EtdFactory
  attr_accessor :etd
  attr_accessor :primary_pdf_file
  attr_accessor :supplemental_files

  def initialize
    @supplemental_files_fs = []
  end

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
    primary_file_set.pcdm_use = FileSet::PRIMARY
    primary_file_set.save
  end

  def attach_supplemental_files
    return unless supplemental_files && supplemental_files.count > 0
    supplemental_files.each do |sf|
      uf = Hyrax::UploadedFile.create(file: File.open(sf))
      AttachFilesToWorkJob.perform_now(etd, [uf])
    end
    mark_supplemental_files
  end

  def mark_supplemental_files
    etd.supplemental_files_fs.each do |fs|
      fs.pcdm_use = FileSet::SUPPLEMENTARY
      fs.embargo = etd.embargo
      fs.save
    end
  end
end
