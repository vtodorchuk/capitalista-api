module Users
  class Create < ApplicationService
    def initialize(params:)
      @params = params
    end

    def call
      user = User.new(@params)
      return Result.fail(user.errors) unless user.save

      tokens = Sessions::IssueTokens.call(user:).value
      Result.ok(user:, tokens:)
    end
  end
end
