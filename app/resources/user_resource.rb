class UserResource
  include Alba::Resource

  attributes :id, :nickname, :email, :created_at

  # Host comes from ActiveStorage::Current.url_options, set per request by ActiveStorage::SetCurrent.
  attribute :avatar_url do |user|
    next unless user.avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(user.avatar, **ActiveStorage::Current.url_options)
  end
end
