class Alangkibar::Validator::Helper
    def self.is_base64(file)
        file.match(%r{^data:(.*?);(.*?),(.*)$}).present?
    end

    def self.is_base64_mime(file_format, file)
        mime = file.match(/data:([a-zA-Z0-9]+\/[a-zA-Z0-9-.+]+).*,.*/)

        if (mime.present?)
            file_format.include? mime[1].split('/')[1]
        end
    end
end