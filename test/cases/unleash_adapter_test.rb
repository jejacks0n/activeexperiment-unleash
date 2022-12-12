# frozen_string_literal: true

require "helper"

class UnleashAdapterTest < ActiveSupport::TestCase
  test "variants defined in unleash with a payload" do
    result = SubjectExperiment.run(id: 1)
    assert_equal "this is the blue variant", result
  end

  test "overriding variants defined in unleash" do
    result = SubjectExperiment.run(id: 3)
    assert_equal "red", result
  end

  test "assigning a variant that doesn't exist in unleash" do
    result = SubjectExperiment.set(variant: :green).run(id: 3)
    assert_equal "green", result
  end

  SubjectExperiment = Class.new(ActiveExperiment::Base) do
    variant(:green) { "green" }
    variant(:red) { "red" } # this won't be overridden

    use_rollout :unleash, toggle_name: "MyExperiment", variants: true
  end
end
