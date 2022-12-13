# frozen_string_literal: true

require "active_experiment"
require "unleash"

module ActiveExperiment
  # Provides an Active Experiment compatible interface for Unleash.
  #
  # This adapter requires an +Unleash::Client+ to be operational. The adapter
  # will attempt to find one, and if no valid client is found, a new one will
  # be created using the global Unleash configuration.
  #
  # The Unleash client can be manually provided to the adapter if desired:
  #
  #   ActiveExperiment::UnleashAdapter.client = Unleash::Client.new
  #
  # Since Unleash implements its own caching and reporting logic, this adapter
  # doesn't need to implement any additional caching or reporting.
  #
  # To use this adapter, simply use the `:unleash` rollout in your experiment:
  #
  #   class MyExperiment < ActiveExperiment::Base
  #     variant(:red) { "red" }
  #     variant(:blue) { "blue" }
  #
  #     use_rollout :unleash, toggle_name: "MyExperiment"
  #   end
  #
  # Given the above example, we can now create a feature toggle in Unleash with
  # the name "MyExperiment", and add the "red" and "blue" variants to it. Now
  # when our experiment is run, a variant will be assigned using Unleash.
  #
  #   MyExperiment.run(current_user) # => "red" or "blue"
  #
  # When creating the variants in Unleash you might notice that a payload can
  # be provided for each variant, which can be used in our experiment by using
  # +:unleash_variant_payload+ when registering the variants:
  #
  #   class MyExperiment < ActiveExperiment::Base
  #     variant(:red, :unleash_variant_payload)
  #     variant(:blue, :unleash_variant_payload)
  #
  #     use_rollout :unleash, toggle_name: "MyExperiment"
  #   end
  #
  # Now if a payload has been provided for the variants in our Unleash feature
  # toggle, that payload will be used as the result of the experiment:
  #
  #   MyExperiment.run(current_user) # => "red payload" or "blue payload"
  #
  # A shortcut for the above, is to tell the rollout that we want to use the
  # variants as they're defined in Unleash. For example, we don't need to
  # register any variants if there are some defined on our Unleash feature
  # toggle:
  #
  #   class MyExperiment < ActiveExperiment::Base
  #     use_rollout :unleash, toggle_name: "MyExperiment", variants: true
  #   end
  #
  # More complex variant scenarios can be crafted this way; for example:
  #
  #   class MyExperiment < ActiveExperiment::Base
  #     variant(:green) { "green" } # this variant is not in Unleash.
  #     variant(:red) { "red" } # this variant won't be overridden,
  #
  #     # This will add the blue variant from Unleash, but won't override red.
  #     use_rollout :unleash, toggle_name: "MyExperiment", variants: true
  #   end
  module UnleashAdapter
    def self.client=(unleash_client) # :nodoc:
      @client = unleash_client
    end

    def self.client # :nodoc:
      @client ||= begin
        client = defined?(UNLEASH) ? UNLEASH : nil
        client ||= Rails.configuration.try(:unleash) if defined?(Rails)
        client || Unleash::Client.new
      end
    end

    # This Rollout uses Unleash to determine if an experiment should be
    # skipped, and subsequently, which variant to assign.
    #
    # The experiment will be skipped if the Unleash feature toggle:
    #   - isn't found
    #   - isn't active
    #   - has no variants defined
    #
    # When using this Rollout, the +Mixin+ will be included in the experiment.
    class Rollout < ActiveExperiment::Rollouts::BaseRollout
      delegate :client, to: UnleashAdapter

      register_as :unleash # register as a usable rollout

      # Augments a given experiment class with Unleash functionality and can
      # register the variants defined on the Unleash feature toggle.
      def self.augment(experiment_class, toggle_name, variants: false, **)
        experiment_class.include(Mixin).unleash_toggle_name = toggle_name
        return unless variants

        feature = Unleash.toggles.find { |t| t["name"] == toggle_name } || {}
        experiment_class.register_unleash_variants(feature.fetch("variants", []))
      end

      # Requires a +toggle_name+ option. The +variants+ option will register
      # the variants defined on the Unleash feature toggle.
      def initialize(...)
        super
        toggle_name = @rollout_options[:toggle_name]

        raise ArgumentError, "Unleash client not available" unless client
        raise ArgumentError, "Missing toggle_name option" unless toggle_name

        self.class.augment(@experiment_class, toggle_name, **@rollout_options)
      end

      # Calls +variant_for+, which sets the experiment variant and payload if a
      # variant is assigned. This optimizes not having to ask Unleash twice.
      def skipped_for(experiment)
        !!variant_for(experiment)
      end

      # Asks Unleash which variant to assign, and sets that variant and payload
      # on the experiment so it can be used within the variant blocks.
      def variant_for(experiment)
        context = experiment.unleash_context
        variant = client.get_variant(experiment.unleash_toggle_name, context)
        if variant.enabled
          name = experiment.variant || variant.name.to_sym
          experiment.set(variant: name, unleash_variant_payload: variant.payload)
        end

        nil
      end
    end

    # This functionality is included in all experiments that use this adapters
    # +Rollout+ and doesn't need to be included manually.
    module Mixin
      extend ActiveSupport::Concern

      included do
        # The default Unleash feature toggle name to use for this experiment.
        class_attribute :unleash_toggle_name, instance_accessor: false
      end

      module ClassMethods
        # Register each of the Unleash variants to return whatever the variant
        # payload was set to when resolving the variant.
        def register_unleash_variants(unleash_variants)
          unleash_variants.each do |variant|
            name = variant["name"].to_sym
            next if variants[name].present?

            fallback = variant.dig("payload", "value")
            variant(name.to_sym) { unleash_variant_payload || fallback }
          end
        end
      end

      # A sane default is to provide the unique +run_key+ as the +user_id+, but
      # this can be overridden to use a real +user_id+ and/or +session_id+.
      def unleash_context
        Unleash::Context.new(user_id: run_key)
      end

      # The default is to return the value from the Unleash variant payload,
      # but this can be overridden to return something more specific from it.
      def unleash_variant_payload
        options.dig(:unleash_variant_payload, "value")
      end

      # The Unleash feature toggle name used when querying Unleash, which can
      # be overridden to use something other than the default class attribute.
      def unleash_toggle_name
        self.class.unleash_toggle_name
      end
    end
  end
end
