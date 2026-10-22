JWTSessions.algorithm = "HS256"
JWTSessions.encryption_key = Rails.application.credentials.jwt_secret!
JWTSessions.access_exp_time = 15.minutes.to_i
JWTSessions.refresh_exp_time = 30.days.to_i
JWTSessions.token_store = :redis, {
  redis_url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  token_prefix: "capitalista_api_jwt_"
}
