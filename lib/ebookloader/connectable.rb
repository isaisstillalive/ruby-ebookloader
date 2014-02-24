# coding: utf-8

module EBookloader
  module Connectable
    protected

    def get uri, options = {}
      conn = Faraday.new url: (uri.scheme + '://' + uri.host) do |faraday|
        faraday.request :url_encoded
        # faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
      conn.get uri.request_uri, options[:params] do |g|
        g.headers.merge! options[:headers] if options[:headers]
        g.headers['Connection'] = 'Keep-Alive';
      end
    end
  end
end
