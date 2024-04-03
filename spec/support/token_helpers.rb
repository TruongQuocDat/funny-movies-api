# frozen_string_literal: true

module TokenHelpers
  def generate_token_for(user)
    Devise::JWT::TestHelpers.auth_headers({}, user)['Authorization'].split.last
  end
end

RSpec.configure do |config|
  config.include TokenHelpers
end
