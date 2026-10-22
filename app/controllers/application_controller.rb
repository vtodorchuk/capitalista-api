class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  include ActiveStorage::SetCurrent

  rescue_from JWTSessions::Errors::Unauthorized do
    render_error(:unauthorized, "unauthorized", "Missing, invalid or expired token")
  end

  rescue_from ActionController::ParameterMissing do |error|
    render_error(:bad_request, "bad_request", error.message)
  end

  private

  def current_user
    @current_user ||= User.find_by(id: payload["user_id"])
  end

  # Shared error envelope for every non-2xx response.
  def render_error(status, code, message, details: nil)
    render status:, json: {
      error: { code:, message:, details:, request_id: request.request_id }.compact
    }
  end

  def render_rate_limited
    render_error(:too_many_requests, "rate_limited", "Too many requests, try again later")
  end
end
