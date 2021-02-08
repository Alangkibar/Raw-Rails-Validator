require_relative 'rules'

module Alangkibar::Validator::Validate
    def self.make(rules, params)
        build_validation(rules, params)
    end

    def self.build_validation(rules, params)
        errors = []
        if rules.first.present?
            rules.first.map do |rule|
                if rule[1].match('regex')
                    extracted_rule = rule[1]
                    value = extractField(params, rule[0].split('.'))

                    if extracted_rule.match(/(:)/)
                        validation = Alangkibar::Validator::Rules.new.send("validate_#{extracted_rule.split(':')[0]}", [key: rule[0], value: value], extracted_rule.split(':')[1])
                    else
                        validation = Alangkibar::Validator::Rules.new.send("validate_#{extracted_rule}", [key: rule[0], value: value])
                    end
                    
                    errors << validation if validation.present?
                else
                    rule[1].split('|').map do |extracted_rule|
                        value = extractField(params, rule[0].split('.'))
                        
                        if extracted_rule.match(/(:)/)
                            validation = Alangkibar::Validator::Rules.new.send("validate_#{extracted_rule.split(':')[0]}", [key: rule[0], value: value], extracted_rule.split(':')[1])
                        else
                            validation = Alangkibar::Validator::Rules.new.send("validate_#{extracted_rule}", [key: rule[0], value: value])
                        end
                        
                        errors << validation if validation.present?
                    end
                end
            end
        end
        
        return errors
    end

    def self.extractField(data, field)
        value = data
        field.map do |val|
            if !value.blank?
                value = value[val]
            end
        end

        return value
    end
end