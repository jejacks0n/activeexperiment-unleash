# frozen_string_literal: true

Unleash.configure do |config|
  config.url = "http://localhost:4242/api/"
  config.app_name = "activeexperiment-unleash"
  config.environment = "development"
  config.bootstrap_config = Unleash::Bootstrap::Configuration.new(
    file_path: File.expand_path("../bootstrap_unleash.json", __FILE__),
  )
end
