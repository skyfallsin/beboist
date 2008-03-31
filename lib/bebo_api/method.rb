require 'ostruct'
module BeboAPI
  class BeboConnectionNotEstablished < StandardError
    def initialize(*args)
      super("No connection to the Bebo API established. You may have to call :initialize_bebo_connection "+
            "in your ApplicationController")
    end
  end
  
  class Method < OpenStruct
    def initialize(*args)
      super(*args)
      verify
      @bebo_parent_name = parent.to_s.gsub("Bebo", "").downcase
      @bebo_method_name = "#{@bebo_parent_name}.#{method_name.camelize(:lower)}"
    end
    
    def verify
      check_binding
      check_and_cleanup_parameter_types  
    end 
    
    def check_binding
      if binding.has_key?(:REQUIRED)
        required_keys = binding.delete(:REQUIRED)
        required_keys == [:any_one_key] ? check_any_one_key_required : 
                                          check_required_keys_with(required_keys)
      else
        check_required_keys_with(binding.keys)
      end
    end
    
    def check_any_one_key_required
      valid_parameters_flag = false
      binding.keys.each { |key|
        valid_parameters_flag = parameters.keys.include?(key) 
        break if valid_parameters_flag
      }
      raise BeboAPI::MissingParameterError,
            "One of these keys: #{binding.keys.collect{|x| ":"+x.to_s}.join(", ")} "+
            "must be specified" unless no_valid_parameters_flag
    end
    
    def check_required_keys_with(required_key_set)
      c = required_key_set - parameters.keys
      raise BeboAPI::MissingParameterError,
            "Missing the following keys - #{c.collect{|x| ":"+x.to_s}.join(", ")}" unless c.empty?
    end
    
    def check_and_cleanup_parameter_types
      parameters.each_pair do |key,value|        
        check_parameter_types(binding[key], value)
        parameters[key] = [value].flatten if binding[key].include?(Array)
      end
    end
    
    def check_parameter_types(valid_klasses, parameter)
      valid_flag = false
      valid_klasses.each { |klass|
        valid_flag = parameter.is_a?(klass)
        break if valid_flag
      }
      raise BeboAPI::InvalidParameterTypeError,
            ":#{key} requires a value of type #{binding[key].join(', ')}" unless valid_flag
    end
    
    def call_method
      raise BeboAPI::BeboConnectionNotEstablished unless BeboAPI::Base.connection
      parameters = sanitize!
      RAILS_DEFAULT_LOGGER.info "RBEBO:: Calling #{@bebo_method_name}(#{parameters.inspect})"
      BeboAPI::Base.connection.call_bebo_method(@bebo_method_name, parameters)
    end
    
    def sanitize!
      parameters.each_pair {|key,value|
        parameters[key] = value.collect(&:to_s).join(",") if value.is_a?(Array)
      }.stringify_keys
    end
  end
end