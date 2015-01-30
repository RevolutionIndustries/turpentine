module Turpentine

  def self.purge (path)
    make_request path, Net::HTTP::Purge
  end

  def self.ban (path)
    make_request path, Net::HTTP::Ban
  end

  private

  def self.make_request(path, request_method)
    host =  Rails.application.config.turpentine['host']
    protocol = Rails.application.config.turpentine['protocol']
    base = "#{protocol}://#{host}"
    uri = URI.parse "#{base}#{path}"

    Rails.logger.info "#{request_method::METHOD}: #{base}#{path}"
    Net::HTTP.start(uri.host, uri.port) do |http|
      presp = http.request request_method.new uri.request_uri
      puts "#{presp.code}: #{presp.message}"
      unless (200...400).include? presp.code.to_i
        Rails.logger.error "A problem occurred. PURGE was not performed."
      end
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
