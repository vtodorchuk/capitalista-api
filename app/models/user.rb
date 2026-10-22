class User < ApplicationRecord
  include Argon2Password

  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/webp].freeze
  AVATAR_MAX_SIZE = 5.megabytes

  has_one_attached :avatar

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :nickname, with: ->(nickname) { nickname.strip }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :nickname, presence: true, uniqueness: { case_sensitive: false },
                       length: { in: 3..30 }, format: { with: /\A[a-zA-Z0-9_.]+\z/ }
  validate :avatar_is_valid_image

  private

  def avatar_is_valid_image
    return unless avatar.attached?

    errors.add(:avatar, "must be a PNG, JPEG or WebP image") unless avatar.content_type.in?(AVATAR_CONTENT_TYPES)
    errors.add(:avatar, "must be smaller than 5 MB") if avatar.byte_size > AVATAR_MAX_SIZE
  end
end
