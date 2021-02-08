class Alangkibar::Validator::Rules
    # required
    def validate_required(params)
        if params.first[:value].blank?
            params.first[:key]+" must be filled"
        end
    end

    # email
    def validate_email(params)
        if !params.first[:value].match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/)
            params.first[:key]+" invalid email format"
        end
    end

    # regex:{regular_expression}
    def validate_regex(params, conds)
        if params.first[:value].match(Regexp.new(conds))
            params.first[:key]+" invalid format"
        end
    end

    # unique:{table,field}
    def validate_unique(params, conds)
        sql = "SELECT * FROM #{conds.split(',')[0]} WHERE #{conds.split(',')[1]} = '#{params.first[:value]}'"
        result = ActiveRecord::Base.connection.execute(sql).first
        
        if result.present?
            params.first[:key]+" is taken"
        end
    end

    # in:{cond1,cond2,cond3}
    def validate_in(params, conds)
        if params.first[:value].present?
            if !conds.split(',').include?(params.first[:value])
                params.first[:key]+" is not allowed"
            end
        end
    end

    def validate_array(params)
        if !params.first[:value].kind_of?(Array)
            return params.first[:key]+" must be filled with array"
        end
    end

    def validate_file(params, conds)
        value = params.first[:value]
        
        if value.kind_of?(Array)
            value.map do |file|
                validate = validate_file_content(file, conds)
                if validate.present?
                    return params.first[:key]+" "+validate
                end
            end

            return false
        elsif value.kind_of?(String)
            validate = validate_file_content(value, conds)
            if validate.present?
                return params.first[:key]+" "+validate
            end
        else
            params.first[:key]+" must be filled with string or array"
        end
    end

    # exists:{table,field}
    def validate_exists(params, conds)
        sql = "SELECT * FROM #{conds.split(',')[0]} WHERE #{conds.split(',')[1]} = '#{params.first[:value]}'"
        result = ActiveRecord::Base.connection.execute(sql).first
        
        if result.blank?
            params.first[:key]+" not found"
        end
    end

    private

    def validate_file_content(file, conds)
        file_type = conds.split(',')[0]
        file_format = conds.split(',')
        file_format.slice!(0)

        if file_type == 'base64'
            if !Alangkibar::Validator::Helper.is_base64(file)
                return "must be base64"
            end
            
            if !Alangkibar::Validator::Helper.is_base64_mime(file_format, file)
                return "extension is not allowed, must be #{file_format.join(', ')}"
            end
        else
            # Validate for file
        end
    end
end