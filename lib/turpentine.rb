require 'turpentine/railtie' if defined?(Rails)

module Turpentine

  def self.purge (path)
    make_request path, Net::HTTP::Purge
  end

  def self.ban (path)
    make_request path, Net::HTTP::Ban
  end

  private

  def self.make_request(path, request_method)
    return unless Rails.application.config.turpentine['enabled']
    host =  Rails.application.config.turpentine['host']
    protocol = Rails.application.config.turpentine['protocol']
    base = "#{protocol}://#{host}"
    uri = URI.parse "#{base}#{path}"

    Rails.logger.info "Turpentine: #{request_method::METHOD}: #{base}#{path}"

    begin
      Net::HTTP.start(uri.host, uri.port) do |http|
        presp = http.request request_method.new uri.request_uri
        unless (200...400).include? presp.code.to_i
          raise "responce code #{presp.code}"
        end
      end
    rescue
      raise "Turpentine cache delete issue: #{request_method::METHOD}: #{base}#{path}"
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
