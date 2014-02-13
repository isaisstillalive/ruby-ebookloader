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
            @loaded = lazy_load
        end
        
        def lazy_load
            true
        end
    end
end
