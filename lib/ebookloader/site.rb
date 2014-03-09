# coding: utf-8

module EBookloader
  # @!parse class Site < Site::Base; end
  # @!parse class Site::Base; end
  class Site < Class.new
    Base = self.superclass

    require_relative 'site/base'

    require_relative 'site/comic_meteor'
    require_relative 'site/champion_tap'
    require_relative 'site/gangan_online'
    require_relative 'site/tonarino_yj'
    require_relative 'site/aoharu_online'
    require_relative 'site/d_manga_online'
    require_relative 'site/comic_clear'
    require_relative 'site/pixiv'
    require_relative 'site/seiga'
  end
end
