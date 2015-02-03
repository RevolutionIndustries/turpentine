module Turpentine
  class Railtie < Rails::Railtie

    initializer "turpentine.configure_rails_initialization" do |app|
      # load config
      app.config.turpentine = app.config_for :turpentine

      # require classes needed to use Turpentine
      require 'turpentine/esi_support'
      require 'turpentine/esi_renderable'
    end
  end
end