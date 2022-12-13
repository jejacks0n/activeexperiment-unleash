# frozen_string_literal: true

require "helper"

class UnleashAdapterTest < ActiveSupport::TestCase
  test "variants defined in unleash with a payload" do
    result = SubjectExperiment.run(id: 1)
    assert_equal "blue payload", result
  end

  test "overriding variants defined in unleash" do
    result = SubjectExperiment.run(id: 2)
    assert_equal "red", result
  end

  test "assigning a variant that doesn't exist in unleash" do
    result = SubjectExperiment.set(variant: :green).run(id: 3)
    assert_equal "green", result
  end

  test "a feature toggle that doesn't exist in unleash" do
    MissingToggleExperiment = Class.new(SubjectExperiment) do
      use_rollout :unleash, toggle_name: "MissingToggle"
    end

    result = MissingToggleExperiment.run(id: 4)
    assert_equal "control", result
  end

  SubjectExperiment = Class.new(ActiveExperiment::Base) do
    control { "control" }
    variant(:green) { "green" }
    variant(:red) { "red" } # this won't be overridden

    use_rollout :unleash, toggle_name: "MyExperimentToggle", variants: true
  end
end
