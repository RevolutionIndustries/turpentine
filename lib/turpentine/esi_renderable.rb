module Turpentine
  module EsiRenderable

    @@esi_enabled  = Rails.application.config.turpentine['enabled']
    @@esi_force_on = Rails.application.config.turpentine['force_on']

    # @TODO support lazy template finding - render partial: 'butts' doesn't work
    # @TODO support collection without as:
    # @TODO add support for   <%= render partial: "articles/chunk", locals: {chunk: chunk, step: step} %>  the chunk object doesnt make it
    # need to auto detect this and convert it to class: 'Chunk', as: 'chunk', id: chunk.id
    def render_esi(options = nil, extra_options = {}, &block)
      options = options.with_indifferent_access

      # insert varnish esi markup
      if (@@esi_enabled and request.headers["HTTP_X_VARNISH"]) or @@esi_force_on
        if options.has_key? :collection
          return esi_render_collection(options, extra_options, &block).html_safe
        else
          return esi_render_one(options, extra_options, &block).html_safe
        end

      # or just insert the regular markup
      else
        if options[:locals].present? and options[:locals].has_key?(:as) and options[:locals].has_key?(:class) and options[:locals].has_key?(:id)
          options[:locals][options[:locals][:as]] = Object.const_get(options[:locals][:class]).find(options[:locals][:id])
          options[:locals] = options[:locals].except(:as, :class, :id)
        end
        render options, extra_options, &block
      end
    end

    private

    def locals_to_query(locals)
      model_keys = {}
      locals.each do |key, value|
        if value.is_a? ActiveRecord::Base
          model_keys["esi_#{key}_class"] = value.class.name
          model_keys["esi_#{key}_id"] = value.id
          locals.except!(key)
        end
      end
      URI.encode_www_form(locals.merge(model_keys))
    end

    def esi_render_one(options = nil, extra_options = {}, &block)
      # show edge side include for varnish

      if options[:locals] and options[:locals][:cache_per_user]
        path = "/esi/user-partials/#{options[:partial].parameterize}"
      else
        path = "/esi/partials/#{options[:partial].parameterize}"
      end

      if options.has_key? 'locals'
        # add locals into the get request
        path += '?' + locals_to_query(options[:locals].except(:cache_per_user))
      end
      "<esi:include src=\"#{path}\" >"
    end

    def esi_render_collection(options = nil, extra_options = {}, &block)
      result = ''

      # convert render_esi partial: 'my/tubs', collection: @articles, as: article
      # to >> render_esi partial: 'my/tubs', locals: {article: article}
      filtered_options = options.except(:collection)
      filtered_options[:locals] ||= {}
      options[:collection].each do |item|
        options[:as].to_sym
        if options[:as].empty?
          filtered_options[:locals][item.class.name.downcase] = item
        else
          filtered_options[:locals][options[:as]] = item
        end

        result += esi_render_one filtered_options, extra_options, &block
      end
      return result
    end

  end
end
