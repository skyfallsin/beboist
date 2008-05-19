# Install hook code here
RAILS_ENV ||= ENV["RAILS_ENV"]
file = File.join(RAILS_ROOT, "config", "bebo.yml")
env_settings = YAML.load(File.open(file))[RAILS_ENV]
ENV["BEBO_CALLBACK_PATH"] = env_settings["callback_path"]

require 'bebo_connection'
require 'bebo_controller_extensions'
require 'bebo_view_extensions'
require 'bebo_routing_extensions'
require 'bebo_api'

ActionController::Base.send(:include, BeboControllerExtensions)
ActionView::Helpers::AssetTagHelper.send(:include, BeboViewExtensions::AssetTagHelper)