require 'uri'
require 'net/https'

module OpenprojectApi
	class Client
		attr_accessor :endpoint
		attr_accessor :apikey
		
		def initialize(endpoint:, apikey:)
			self.endpoint = endpoint
			self.apikey   = apikey
		end
		
		def request(resource, query: {}, &block)
			uri = URI.join(endpoint, resource)
			uri.query = URI.encode_www_form(query)
			
			response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme=='https') do |http|
				request = yield(uri)
				
				request.basic_auth('apikey', apikey)
				
				http.request(request)
			end
			
			if response.is_a?(Net::HTTPOK)
				JSON.parse(response.body)
			else
				response.error!
			end
		end
		
		def get(resource, *args)
			request(resource, *args) do |uri|
				Net::HTTP::Get.new(uri.request_uri)
			end
		end
	end
end
