module Turpentine
  class Engine < Rails::Engine

    initializer "turpentine.configure_rails_initialization" do |app|
      # load config
      app.config.turpentine = app.config_for :turpentine

      # require classes needed to use Turpentine
      require 'turpentine/esi_support'
      require 'turpentine/esi_renderable'
      # require 'turpentine/esi_controller'
    end
  end
end
