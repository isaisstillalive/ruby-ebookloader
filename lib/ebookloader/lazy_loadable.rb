# coding: utf-8

module EBookloader
    module LazyLoadable
        private
        def self.included mod
            class << mod
                def attr_lazy_reader *names
                    names.each do |name|
                        define_method name do
                            var = proc{ instance_variable_get("@#{name}") }
                            var.call || (load; var.call)
                        end
                    end
                end

                def attr_lazy_accessor *names
                    attr_lazy_reader *names
                    attr_writer *names
                end
            end
        end

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

        def lazy_load
            true
        end

        def lazy_collection source, regexp, reverse = false, &block
            block = proc{ |m| m } if block.nil?

            enum = Enumerator.new do |yielder|
                pos = 0
                loop do
                    match = regexp.match(source, pos)
                    break if match.nil?

                    pos = match.offset(0)[1]

                    match = block.call(match)
                    yielder << match
                end
            end
            enum = enum.reverse_each if reverse
            enum.lazy
        end
    end
end
