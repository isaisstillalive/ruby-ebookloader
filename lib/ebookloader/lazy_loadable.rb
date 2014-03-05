# coding: utf-8

module EBookloader
  # 遅延読み込みを行うモジュール
  module LazyLoadable
    private

    # LazyLoadableをincludeした際に定義されるクラスメソッド
    module ClassMethod
      private

      def attr_lazy_reader *names
        names.each do |name|
          define_method name do
            var = proc{ instance_variable_get("@#{name}") }
            var.call || (load; var.call)
          end
        end
        nil
      end

      def attr_lazy_accessor *names
        attr_lazy_reader *names
        attr_writer *names
      end
    end

    def self.included mod
      mod.extend ClassMethod
    end

    # 読み込みを行う
    # @return [Boolean] 成功したか
    # @see LazyLoadable#lazy_load
    def load
      return if @loaded
      @loaded = true
      begin
        @loaded = lazy_load
      rescue
        @loaded = false
        raise
      end
    end

    # 読み込みの実処理
    # @return [Boolean] 成功したか。trueを返した場合、それ以降の読み込みは行われません
    # @abstract includeしたクラスで上書きする
    # @see LazyLoadable#load
    def lazy_load
      true
    end
  end
end
