module Api
  module V1
    class UsersController < ApplicationController
      rate_limit to: 5, within: 10.minutes, only: :create, with: -> { render_rate_limited }

      # POST /api/v1/users
      def create
        result = Users::Create.call(params: user_params)

        if result.success?
          render status: :created, json: { user: UserResource.new(result.value[:user]).to_h, tokens: result.value[:tokens] }
        else
          render_error(:unprocessable_content, "validation_failed", "User could not be created",
                       details: result.error.to_hash)
        end
      end

      private

      def user_params
        params.expect(user: [ :nickname, :email, :password, :avatar ])
      end
    end
  end
end
