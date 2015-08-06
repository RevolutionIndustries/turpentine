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
          return markup_for_collection(options, extra_options, &block).html_safe
        else
          return markup_for_one(options, extra_options, &block).html_safe
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

    # build the esi include tag with url variables we need to render the partial
    def markup_for_one(options = nil, extra_options = {}, &block)
      path = Turpentine::src_path_for(options, extra_options, &block)
      "<esi:include src=\"#{path}\" >"
    end

    # build a bunch of esi includes
    def markup_for_collection(options = nil, extra_options = {}, &block)
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

        result += markup_for_one(filtered_options, extra_options, &block)
      end
      return result
    end

  end
end
