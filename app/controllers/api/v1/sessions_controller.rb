module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authorize_access_request!, only: :destroy
      before_action :authorize_by_refresh_header!, only: :refresh
      
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rate_limited }
      rate_limit to: 30, within: 10.minutes, only: :refresh, with: -> { render_rate_limited }

      # POST /api/v1/sign_in
      def create
        result = Sessions::SignIn.call(email: params.require(:email), password: params.require(:password))

        if result.success?
          render json: { user: UserResource.new(result.value[:user]).to_h, tokens: result.value[:tokens] }
        else
          render_error(:unauthorized, "invalid_credentials", "Invalid email or password")
        end
      end

      # POST /api/v1/refresh (refresh token in the X-Refresh-Token header)
      def refresh
        result = Sessions::Refresh.call(refresh_token: found_token, user_id: payload["user_id"])

        if result.success?
          render json: { user: UserResource.new(result.value[:user]).to_h, tokens: result.value[:tokens] }
        else
          render_error(:unauthorized, "invalid_session", "Session is no longer valid")
        end
      end

      # DELETE /api/v1/sign_out
      def destroy
        JWTSessions::Session.new(payload:).flush_by_access_payload
        head :no_content
      end
    end
  end
end
