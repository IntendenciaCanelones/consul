class LocalCensusRecord < ApplicationRecord
  before_validation :sanitize

  validates :document_number, presence: true
  validates :document_type, presence: true
  validates :document_type, inclusion: { in: ["1", "2", "3"], allow_blank: true }
  validates :date_of_birth, presence: true
  validates :postal_code, presence: true
  validates :document_number, uniqueness: { scope: :document_type }

  validates :postal_code, inclusion: { in: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"], allow_blank: false }

  scope :search, ->(terms) { where("document_number ILIKE ?", "%#{terms}%") }

  private

    def sanitize
      self.document_type   = self.document_type&.strip
      self.document_number = self.document_number&.strip
      self.postal_code     = self.postal_code&.strip
    end
end
