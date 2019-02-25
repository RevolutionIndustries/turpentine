require 'turpentine/railtie' if defined?(Rails)
require 'net/http'

module Turpentine
  @@delay = true
  @@requests = Hash.new

  def self.purge(path)
    add_request path, Net::HTTP::Purge
  end

  def self.ban(path)
    add_request path, Net::HTTP::Ban
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

  def self.flush_requests
    @@requests.each_value do |uri_hash|
      self.make_request(uri_hash[:uri], uri_hash[:method])
    end
    @@requests = Hash.new
    nil
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

  def self.add_request(path, method)
    host     = Rails.application.config.turpentine['host']
    protocol = Rails.application.config.turpentine['protocol']
    base     = "#{protocol}://#{host}"
    uri      = "#{base}#{path}"

    if @@delay
      @@requests["#{method}#{uri}"] = {uri: uri, method: method}
    else
      self.make_request(uri, method)
    end
  end

  def self.make_request(path, method)
    return unless Rails.application.config.turpentine['enabled']

    host = Rails.application.routes.default_url_options[:host]

    Rails.logger.info "Turpentine: #{method}: #{path}"

    begin
      uri = URI.parse path
      Net::HTTP.start(uri.host, uri.port) do |http|
        req = method.new(uri.request_uri, {'Host' => host})
        resp = http.request(req)

        case resp.code.to_i
        when 200...399
          Rails.logger.info resp.body
        else
          Rails.logger.warn resp.body
        end
      end
    rescue => e
      Rails.logger.warn "Turpentine cache delete issue: #{method}: #{path} #{e.message}"
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
