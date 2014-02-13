module EBookloader
    class Book
        class Direct < Book
            private

            def lazy_load
                @name ||= Pathname(@uri.path).basename.to_s
            end

            def save_core dir_path
                file_path = dir_path + name
                write file_path, uri
            end
        end
    end
end
