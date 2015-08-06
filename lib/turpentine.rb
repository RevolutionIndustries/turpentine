require 'turpentine/railtie' if defined?(Rails)

module Turpentine

  def self.purge (path)
    make_request path, Net::HTTP::Purge
  end

  def self.ban (path)
    make_request path, Net::HTTP::Ban
  end

  def self.src_path_for(options = nil, extra_options = {}, &block)

    # base path
    path = "/esi/"

    # user specific?
    if options[:locals] and options[:locals][:cache_per_user]
      path += "user-partials/"
    else
      path += "partials/"
    end

    # partial name
    path += options[:partial].parameterize

    # optional variables
    if options.has_key? 'locals'
      path += '?' + locals_to_query(options[:locals].except(:cache_per_user))
    end

    path
  end

  private

  def self.locals_to_query(locals)
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

  def self.make_request(path, request_method)
    return unless Rails.application.config.turpentine['enabled']
    host      = Rails.application.routes.default_url_options[:host]
    vhost     = Rails.application.config.turpentine['host']
    vprotocol = Rails.application.config.turpentine['protocol']
    vbase     = "#{vprotocol}://#{vhost}"
    vuri      = URI.parse "#{vbase}#{path}"

    Rails.logger.info "Turpentine: #{request_method::METHOD}: #{vbase}#{path}"

    begin
      Net::HTTP.start(vuri.host, vuri.port) do |http|
        req = request_method.new(vuri.request_uri, initheader = {'Host' => host})
        resp = http.request(req)

        case resp.code.to_i
        when 200...399
          Rails.logger.info resp.body
        else
          Rails.logger.warn resp.body
        end
      end
    rescue => e
      raise "Turpentine cache delete issue: #{request_method::METHOD}: #{vbase}#{path} #{e.message}"
    end
  end

end

# add BAN and PURGE methods to NET
module Net
  class HTTP::Ban < HTTPRequest
        METHOD='BAN'
        REQUEST_HAS_BODY = false
        RESPONSE_HAS_BODY = true
  end

  class HTTP::Purge < HTTPRequest
        METHOD='PURGE'
        REQUEST_HAS_BODY = false
        RESPONSE_HAS_BODY = true
  end
end
