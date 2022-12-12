# frozen_string_literal: true

require "active_support/core_ext/kernel/reporting"
require "minitest/mock"
require "simplecov"
require "activeexperiment"

SimpleCov.start do
  add_filter "test/"
end

require "active_experiment/unleash_adapter"

ActiveExperiment.logger = Logger.new(nil)

require "support/unleash_helpers"

require "active_support/testing/autorun"
