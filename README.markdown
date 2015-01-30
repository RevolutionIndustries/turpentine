Turpentine
==========

Add Varnish support to your Ruby on Rails Application.

* Write Edge Side Includes using standard render partials syntax
* Automatic Varnish detection for use in dev and production
* Clear Varnish cache using BAN and PURGE requests
* Render ESI's using a multi-request like flow that still displays correctly for development


Setup
=====

Turpentine was built on Rails 4.2 and I make no promises.

Add Turpentine to your Gemfile:

```ruby
gem 'turpentine', :git => 'git@github.com:RevolutionIndustries/turpentine.git'
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
  session_name: 'my_session' # name of the session cookie to intercept

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

Edge Side Include Rendering
============================


A helper is defined for rendering esi partials the same way you'd normally render partials.

```erb
  # A typical rails partial render
  <%= render partial: 'articles/byline', locals: {user: @article.user} %>

  # Rendering the same partial using Edge Side Includes
  # The html will be replaced with:
  # <esi src="/esi/partials/articles-byline?esi_user_class=User&esi_user_id=10" />
  <%= render_esi partial: 'articles/byline', locals: {user: @article.user} %>

  # ESI using per-user cacheable urls (you have to set this up in Varnish VCL)
  # The html will be replaced with:
  # <esi src="/esi/user-partials/site-nav_top?" />
  <%= render_esi partial: "site/nav_top", locals: {cache_per_user: true} %>
```

Rendering collections works very similarly

```erb
  # A typical rails partial render using collections
  <%= render partial: "articles/card", collection: @related, as: :article %>

  # Rendering the same partial using Edge Side Includes
  # The html will be replaced with one esi per item in the collection:
  # <esi src="/esi/partials/articles-card?esi_article_class=Article&esi_article_id=2002" />
  # <esi src="/esi/partials/articles-card?esi_article_class=Article&esi_article_id=2003" />
  # <esi src="/esi/partials/articles-card?esi_article_class=Article&esi_article_id=2004" />
  # and so on.... one esi for each item in the collection
  <%= render_esi partial: "articles/card", collection: @related, as: :article %>

```

Clearing Cache
==============

```ruby
  # purge request for one url
  Turpentine:purge '/some-dir/some-url'

  # ban request for all tweets for tweet 200 (and any edge side includes I made)
  Turpentine:ban '/tweets/200.*'
  Turpentine:ban '/esi/partials/tweets-card?.*esi_tweet_id=200.*'
```

