module Sessions
  class SignIn < ApplicationService
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.authenticate_by_credentials(email: @email, password: @password)
      return Result.fail(:invalid_credentials) unless user

      tokens = IssueTokens.call(user:).value
      Result.ok(user:, tokens:)
    end
  end
end
