require 'digest/md5'
require 'net/http'
require 'yaml'
require 'json/ext'
require 'json/add/core'
require 'json/add/rails'

BEBO_REMOTE_SERVER      = ENV['BEBO_REMOTE_SERVER']      || "apps.bebo.com" 
BEBO_REMOTE_SERVER_PORT = ENV['BEBO_REMOTE_SERVER_PORT'] || 80
BEBO_REMOTE_SERVER_PATH = ENV['BEBO_REMOTE_SERVER_PATH'] || "/restserver.jsp"

class BeboConnection
  attr_accessor :auth_data, :conn, :session_key
  def initialize(session_key, *args)    
    bebo_settings_file = File.join(RAILS_ROOT, "config", "bebo.yml")
    @auth_data = YAML.load(File.open(bebo_settings_file))[RAILS_ENV]
    @conn = Net::HTTP.new(BEBO_REMOTE_SERVER, BEBO_REMOTE_SERVER_PORT)
    @session_key = session_key
  end

  # Calls the remote method, and returns JSON
  def call_bebo_method(function, parameters={})
    query = build_query(function, parameters)
    response = @conn.start { |http| http.request(query) }.body
    BeboResponseParser.parse(response)
  end

  def build_query(function, parameters={})
    parameters.merge!("method" => function.to_s, "api_key" => @auth_data["api_key"],
                      "format" => "JSON",        "session_key" => @session_key)
    parameters.merge!("sig" => signature(parameters))
    post_request(parameters)
  end
  
  def post_request(parameters={})
    post_request = Net::HTTP::Post.new(BEBO_REMOTE_SERVER_PATH)
    post_request.form_data = parameters
    post_request
  end
  
  def signature(parameters={})
    raise "You need to specify an :api_secret key in your bebo.yml" unless @auth_data["api_secret"]
    # signature requires an alphabetically sorted key-value list joined by ''
    # prepended with the secret key
    parameters = parameters.sort
    parameters.collect!{|x| x.join("=")} # {"a"=>1,"d"=>2,"b"=>3} to ["a=1","b=2","c=3"]
    Digest::MD5.hexdigest(parameters.join + @auth_data["api_secret"])
  end
end

class BeboAPIResponseError < StandardError; end

class BeboResponseParser    
  def self.parse(response)
    @rp = self.new(response)
    @rp.parse
  end
  
  def initialize(response)
    @response = response
    RAILS_DEFAULT_LOGGER.info "RBEBO::Response -> #{@response}"
  end
  
  def parse
    raise(BeboAPIResponseError, @response) if @response.include?("error")
    JSON.unparse(@response)
  end
end