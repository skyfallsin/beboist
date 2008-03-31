class BeboistSettingsGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
  end
  
  def manifest
    record do |m|
      m.directory "/config"
      m.template "bebo.yml", "config/bebo.yml"
    end
  end
  
end