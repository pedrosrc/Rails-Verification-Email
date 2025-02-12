class User < ApplicationRecord
  has_secure_password

  before_create :generate_verification_code

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def generate_verification_code
    self.verification_code = rand(100000..999999).to_s # Generates a 6-digit code
    self.verified = false
  end
end
