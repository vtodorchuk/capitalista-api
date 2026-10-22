module Sessions
  class IssueTokens < ApplicationService
    def initialize(user:)
      @user = user
    end

    def call
      payload = { user_id: @user.id }
      # refresh_by_access_allowed embeds the refresh uid ("ruid") in the access token,
      # which sign_out needs to revoke the whole session.
      tokens = JWTSessions::Session.new(payload:, refresh_payload: payload, refresh_by_access_allowed: true).login

      Result.ok(
        access_token: tokens[:access],
        access_expires_at: tokens[:access_expires_at],
        refresh_token: tokens[:refresh],
        refresh_expires_at: tokens[:refresh_expires_at]
      )
    end
  end
end
