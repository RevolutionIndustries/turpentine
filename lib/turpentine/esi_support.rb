module Turpentine
  module EsiSupport
    extend ActiveSupport::Concern

    included do
      if Rails.application.config.turpentine['enabled']
        before_filter :move_varnish_header_into_cookie

        if Rails.application.config.turpentine['debug_render']
          after_filter :expand_response_esi
        end
      end
    end

    def params_to_locals(params)
      locals = params.except(:partial)
      objects = {}
      remove_keys = []

      # collect all the values into our objects hash
      locals.each do |key, value|
        match = key.to_s.match(/esi_(.+)_(.+)/)
        unless match.nil?
          remove_keys = key.to_sym
          this_obj = objects[match[1]] ||= {}
          this_obj[match[2]] = value
        end
      end

      # locate the objects we found
      objects.each do |key, value|
        locals[key.to_sym] = Object.const_get(value['class']).find(value['id'])
      end
      locals.except(remove_keys)
    end

    private

    def move_varnish_header_into_cookie
      key = '_howtune_session'
      header = "HTTP_X_#{key.upcase}"
      if request.headers[header]
        request.headers['HTTP_COOKIE'] = "#{key}=#{request.headers[header]}"
      end
    end

    def expand_response_esi()
      response.body = expand_esi_in response.body
    end

    def expand_esi_in(text)
      contents = {}

      # recursively render each partial to a string
      text.scan(/(\<esi:include\s+src\=\"(.*?)\"\s*\>)/) do |m|
        unless contents.has_key? m[0]
          logger.info "debug rendering inline esi for #{m[1]}"

          options = esi_option_hash m[1]
          contents[m[0]] = expand_esi_in render_partial_to_string(options)
        end
      end

      # replace text with the recursivly rendered esi text
      contents.each {|key, value| text = text.gsub key, value}

      return text
    end

    def esi_option_hash(path)
      uri = URI('http://site.com'+path)
      hash = Rack::Utils.parse_query(uri.query).symbolize_keys
      hash[:partial] = uri.path.split('/').last.gsub('-', '/')
      hash
    end

    def render_partial_to_string(options)
      # hydrate any :as ,:class, and :id items
      # locals = options.except(:partial, :as, :class, :id)
      locals = params_to_locals options.except(:partial)

      render_to_string partial: options[:partial].gsub(/\-/, '/'), locals: locals
    end
  end
end
