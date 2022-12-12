# frozen_string_literal: true

Unleash.configure do |config|
  config.url = "http://localhost:4242/api/"
  config.app_name = "activeexperiment-unleash"
  config.environment = "development"
  # config.log_level = :debug
  config.custom_http_headers = {
    Authorization: "default:development.unleash-insecure-api-token"
  }
end
