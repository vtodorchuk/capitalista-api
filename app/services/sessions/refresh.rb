module Sessions
  # Rotates the session: the presented refresh token (and its access token) is revoked
  # and a brand-new token pair is issued, so every refresh token is single-use.
  class Refresh < ApplicationService
    def initialize(refresh_token:, user_id:)
      @refresh_token = refresh_token
      @user_id = user_id
    end

    def call
      user = User.find_by(id: @user_id)
      return Result.fail(:invalid_session) unless user

      # Raises JWTSessions::Errors::Unauthorized if the token was already used.
      JWTSessions::Session.new.flush_by_token(@refresh_token)

      tokens = IssueTokens.call(user:).value
      Result.ok(user:, tokens:)
    end
  end
end
