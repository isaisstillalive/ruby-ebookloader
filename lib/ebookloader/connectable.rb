module EBookloader
	module Connectable
		protected

        def get uri, params = nil
            conn = Faraday.new url: (uri.scheme + '://' + uri.host) do |faraday|
                faraday.request :url_encoded
                # faraday.response :logger
                faraday.adapter Faraday.default_adapter
            end
            conn.get uri.request_uri, params do |g|
                # g.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.107 Safari/537.36'
                # g.headers['Referer'] = uri.to_s
            end
        end
	end
end
