module BeboAPI
  module BeboMethodRegistration
    def register_method(name, parameter_binding={})
      #puts "registering #{self}.#{name}(#{parameter_binding.keys.join(", ")})"
      self.class_eval { generate_bebo_method_definition(name, parameter_binding) }
    end
    
    def generate_bebo_method_definition(name, parameter_binding={})
      parameter_binding.each_pair{|key,val| parameter_binding[key] = [val].flatten }
      method_def = <<-ENDSTR
        def self.#{name}(params={})
          self.generate_method(:method_name => "#{name}", 
                               :binding => #{parameter_binding.inspect}, 
                               :parameters => params,
                               :parent => self)
        end
      ENDSTR
      eval(method_def)
    end
  end
  
  class Base < BlankSlate
    cattr_accessor :connection
    extend BeboAPI::BeboMethodRegistration
    
    def self.generate_method(*args)
      BeboAPI::Method.new(*args).call_method 
    end
    
    def self.query(str)
      self.generate_method(:method_name => "query", :binding => {:query => [String]},
                           :parameters => {:query => str}, :parent => self) 
    end
  end
  
  # Thank you, Jim Weirich (RubyConf 2007)
  class BlankSlate
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
  end
end