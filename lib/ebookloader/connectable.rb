# coding: utf-8

module EBookloader
  module Connectable
    protected

    def conn uri
      Faraday.new url: (uri.scheme + '://' + uri.host), :ssl => {:verify => false} do |faraday|
        faraday.request :url_encoded
        # faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    def run_request method, uri, body = nil, headers = {}
      result = conn(uri).run_request method, uri.request_uri, body, headers do |g|
        g.headers['Connection'] = 'Keep-Alive'
      end
      result.body.force_encoding Encoding::UTF_8 if result.body.respond_to? :force_encoding
      result
    end

    def get uri, headers = {}
      run_request :get, uri, nil, headers
    end

    def post uri, body, headers = {}
      run_request :post, uri, body, headers
    end

    def head uri, headers = {}
      run_request :head, uri, nil, headers
    end

    def write file_path, uri, headers = {}
      file_path.open('wb') { |p| p.write(get(uri, headers).body) }
    end

    require_relative 'connectable/pixiv'
    require_relative 'connectable/seiga'
  end
end
