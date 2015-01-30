Turpentine
==========

Add Varnish support to your Ruby on Rails Application.

* Write Edge Side Includes using standard redner partials syntax
* Automatic Varnish detection for use in dev and production
* Clear Varnish cache using BAN and PURGE requests
* Render ESI's using a multi-request like flow that still displays correctly for development


Setup
=====

Turpentine was built on Rails 4.2 and I make no promises.

Add Turpentine to your Gemfile:

```ruby
gem 'turpentine'
```

Run bundle to install it

Create a Turpentine config

```yaml
development:
  enabled: true # tries to auto detect varnish headers, and enable if found
  force_on: false # skip detection, just do it
  debug_render: false # setting to true will render any generated esi tags before the response is sent (slow)
  host: 'localhost:8080' # for ban and purge requests
  protocol: 'http' # for ban and purge requests

test:

production:

```

Load the Turpentine config in your in config/application.rb

```ruby
module MyApplication
  class Application < Rails::Application

    config.turpentine = config_for :turpentine

   end
end
```

Add ESI Support to your controllers in app/controllers/application_controller.rb

```ruby
require 'turpentine/esi_support'
class ApplicationController < ActionController::Base
  include Turpentine::EsiSupport
```

Add ESI Rendering to app/helpers/application_helper.rb

```ruby
require 'turpentine/esi_renderable'
module ApplicationHelper
  include Turpentine::EsiRenderable
```

Add routes for your Edge Side Includes in config/routes.rb

```ruby
  # ESI Rendering
  get 'esi/partials/:partial'      => 'turpentine/esi#view', as: :esi
  get 'esi/user-partials/:partial' => 'turpentine/esi#view', as: :user_esi
```

