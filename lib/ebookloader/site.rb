# coding: utf-8

module EBookloader
    class Site < Class.new
        Base = self.superclass

        class Base
            include Connectable
            include LazyLoadable
            include BookInfo

            attr_reader :uri
            attr_lazy_accessor :title, :author, :books

            def initialize uri, options = {}
                @uri = URI(uri)
                self.update! options
            end

            def == other
                return false unless self.class == other.class
                return false unless self.uri == other.uri

                true
            end

            class << self
                def get_episode_number episode_number
                    return '%02d' % episode_number if episode_number.match /^\d*$/
                    return '%05.2f' % episode_number if episode_number.match /^\d\.\d*$/

                    match = episode_number.match /第(?<first>\d+)(-(?<last>\d+))?(?:話|回)/
                    return episode_number unless match

                    format = match[:last] ? '%02d-%02d' : '%02d'
                    format % [match[:first], match[:last]]
                end

                def get_author author
                    author.gsub(%r{　|<br />}, ', ').gsub(%r{(, |^).*?[/：]}, '\1')
                end
            end
        end

        require_relative 'site/comic_meteor'
        require_relative 'site/champion_tap'
        require_relative 'site/gangan_online'
        require_relative 'site/tonarino_yj'
        require_relative 'site/aoharu_online'
        require_relative 'site/d_manga_online'
    end
end
