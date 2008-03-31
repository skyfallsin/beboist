RAILS_ENV ||= ENV["RAILS_ENV"]
env_settings = YAML.load(File.open(File.join(RAILS_ROOT, "config", "bebo.yml")))[RAILS_ENV]
ENV["BEBO_CALLBACK_PATH"] = env_settings["callback_path"]

require 'bebo_connection'
require 'bebo_controller_extensions'
require 'bebo_view_extensions'
require 'bebo_routing_extensions'
require 'bebo_api'

ActionController::Base.send(:include, BeboControllerExtensions)
ActionView::Helpers::AssetTagHelper.send(:include, BeboViewExtensions::AssetTagHelper)