class RegistrarFeed < ApplicationRecord
  enum status: {
    initialized: 0, # default via table definition
    queued: 1,
    processing: 2,
    completed: 3,
    errored: 4
  }

  has_one_attached :graduation_records # JSON data from registrar
  has_one_attached :report # CSV report of etd publication status

  validates_each :graduation_records do |record, attribute, value|
    record.errors.add(attribute, 'must be attached') unless record.send(attribute).attached?
  end

  scope :by_recently_updated, -> { order(updated_at: :desc) }
end
