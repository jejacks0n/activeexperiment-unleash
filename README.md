# Active Experiment – Unleash Adapter

Provides an [Active Experiment](https://github.com/jejacks0n/activeexperiment) compatible interface for [Unleash](https://github.com/Unleash/unleash-client-ruby).

## Setup

This adapter requires an `Unleash::Client` to be operational. The adapter will attempt to find one, and if no valid client is found, a new one will be created using the global Unleash configuration.

The Unleash client can be manually provided to the adapter if desired:

```ruby
ActiveExperiment::UnleashAdapter.client = Unleash::Client.new
```

Since Unleash implements its own caching and reporting logic, this adapter doesn't need to implement any additional caching or reporting.

## Usage

To use this adapter, simply use the `:unleash` rollout in your experiment:

```ruby
class MyExperiment < ActiveExperiment::Base
  variant(:red) { "red" }
  variant(:blue) { "blue" }

  use_rollout :unleash, toggle_name: "MyExperiment"
end
```

Given the above example, we can now create a feature toggle in Unleash with the name "MyExperiment", and add the "red" and "blue" variants to it. Now when our experiment is run, a variant will be assigned using Unleash.

```ruby
MyExperiment.run(current_user) # => "red" or "blue"
```

When creating the variants in Unleash you might notice that a payload can be provided for each variant, which can be used in our experiment by using `:unleash_variant_payload` when registering the variants:

```ruby
class MyExperiment < ActiveExperiment::Base
  variant(:red, :unleash_variant_payload)
  variant(:blue, :unleash_variant_payload)

  use_rollout :unleash, toggle_name: "MyExperiment"
end
```

Now if a payload has been provided for the variants in our Unleash feature toggle, that payload will be used as the result of the experiment:

```ruby
MyExperiment.run(current_user) # => "red payload" or "blue payload"
```

A shortcut for the above, is to tell the rollout that we want to use the variants as they're defined in Unleash. For example, we don't need to register any variants if there are some defined on our Unleash feature toggle:

```ruby
class MyExperiment < ActiveExperiment::Base
  use_rollout :unleash, toggle_name: "MyExperiment", variants: true
end
```

More complex variant scenarios can be crafted this way; for example:

```ruby
class MyExperiment < ActiveExperiment::Base
  variant(:green) { "green" } # this variant is not in Unleash.
  variant(:red) { "red" } # this variant won't be overridden,

  # This will add the blue variant from Unleash, but won't override red.
  use_rollout :unleash, toggle_name: "MyExperiment", variants: true
end
```

## Download and Installation

Add this line to your Gemfile:

```ruby
gem "activeexperiment-unleash"
```

Or install the latest version with RubyGems:

```bash
gem install activeexperiment-unleash
```

Source code can be downloaded as part of the project on GitHub:

* https://github.com/jejacks0n/activeexperiment-unleash

## License

Active Experiment is released under the MIT license:

* https://opensource.org/licenses/MIT

Copyright 2022 [jejacks0n](https://github.com/jejacks0n)

## Make Code Not War
