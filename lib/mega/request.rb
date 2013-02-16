require 'json'
require 'net/http'
require 'net/https'

module MEGA
  class Request
    EAGAIN = '-3'
    API_URL = 'https://eu.api.mega.co.nz/cs'
    @@counter = rand(0x100000000)
    
    def initialize request, session_id = nil
      @request = request
      if @request.is_a? Hash
        @request = [@request]
      end
      @payload = @request.to_json
      @session_id = session_id
      @sequence_no = (@@counter += 1)
      @uri = API_URL + '?id=' + @sequence_no.to_s
      if @session_id
        @uri += "&sid=#{@session_id}"
      end
      @uri = URI.parse(@uri)
      @uri.port = 443 # SSL please
    end
    
    def run
      result = nil
      req = Net::HTTP::Post.new(@uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      req.body = @payload
      body = EAGAIN
      retries = 4
      while body == EAGAIN do
        @response = Net::HTTP.start(@uri.host, @uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) {|http| http.request(req) }
        body = @response.body
        begin
          result = MEGA::Response.new(JSON.parse(body))
        rescue
          retries -= 1
          sleep 2
          raise :error if retries == 0
          body = EAGAIN
        end
      end
      result
    end
  end
end
