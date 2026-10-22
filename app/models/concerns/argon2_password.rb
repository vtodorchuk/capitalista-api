# Argon2id password hashing with a server-side pepper, stored in password_digest.
module Argon2Password
  extend ActiveSupport::Concern

  MIN_LENGTH = 8
  MAX_LENGTH = 128

  included do
    attr_reader :password

    validates :password, presence: true, on: :create
    validates :password, length: { in: MIN_LENGTH..MAX_LENGTH }, allow_nil: true
  end

  class_methods do
    def hasher
      Argon2::Password.new(secret: Rails.application.credentials.password_pepper!)
    end

    # Runs a hash on a miss so that unknown emails take as long as wrong passwords.
    def authenticate_by_credentials(email:, password:)
      user = find_by(email: email.to_s.strip.downcase)
      return user if user&.authenticate(password.to_s)

      hasher.create("timing-equalizer") unless user
      nil
    end
  end

  def password=(value)
    @password = value
    self.password_digest = value.present? ? self.class.hasher.create(value.to_s) : nil
  end

  def authenticate(value)
    return false if password_digest.blank?

    Argon2::Password.verify_password(value.to_s, password_digest, Rails.application.credentials.password_pepper!) && self
  rescue Argon2::ArgonHashFail
    false
  end
end
