require File.dirname(__FILE__) + '/spec_helper'
require 'net/http'; require 'yaml'; require 'digest/md5'; require 'json'

module BeboConnectionHelpers
  def setup_auth
    @auth_data = {"test" => {"api_secret"=>"asdjfoimc923oijoia;scoidjsa;ijfaks", 
                             "url"=>"http://www.stevec.woolsery.com:8080/restserver.jsp", 
                             "api_key"=>"asoidj1omociasdjofimaowieldkasfkls"}}
    YAML.stub!(:load).and_return(@auth_data)
  end
  
  def setup_parameters
    @parameters = {"a" => 1, "b" => 2 }
    @function = "users.getInfo"
    @merged_parameters = @parameters.merge("method" => @function.to_s,
                                            "api_key" => @auth_data["api_key"], "format" => "JSON")
  end
  
  def new_bebo_connection(session_key="fake_session_key")
    BeboConnection.new(session_key)
  end
end
include BeboConnectionHelpers

describe BeboConnection do  
  context "Initialization" do
    before(:each) { @bconn = new_bebo_connection("fake_session_key") }
    it { @bconn.should_not be_nil }
  end 
  
  context "Initialize => Loading YAML files" do
    before(:each) { setup_auth }
    
    it "should respond to #auth_data" do
      new_bebo_connection.should respond_to(:auth_data) end
    it "should load a hash from a YAML file" do
      YAML.should_receive(:load).and_return(@auth_data); new_bebo_connection end
    it "should have a hash with keys: api_secret, url, api_key" do
      bconn = new_bebo_connection
      ["api_secret", "api_key"].each { |x| bconn.auth_data.should have_key(x) } end
  end
  
  context "Initialize => Starting Net::HTTP" do
    it "should respond to #conn" do
      new_bebo_connection.should respond_to(:conn) end
    it "should call Net::HTTP" do
      Net::HTTP.should_receive(:new).and_return(mock("Net::HTTP")); new_bebo_connection end
  end
  
  context "Building a signature" do
    before(:each) do
      setup_auth; @bconn = new_bebo_connection end

    it "should use Digest::MD5" do
      Digest::MD5.should_receive(:hexdigest); @bconn.signature([]) end
    it "should join the parameters it receives, prepend it with the signature, and MD5 it" do
      param_set = {"a" => 1, "b" => 2, "c" => 3}
      @bconn.signature(param_set).should eql(Digest::MD5.hexdigest(param_set.sort.collect{|x| x.join("=")}.join + 
                                                                   @auth_data["test"]["api_secret"])) end
  end
  
  context "Sanitizing method parameters" do
    
  end
  
  context "Building a Query" do
    before(:each) do
      setup_auth
      setup_parameters
      @bconn = new_bebo_connection
    end
    after(:each) { @bconn.build_query(@function, @parameters) }
    
    it "should merge default values into the parameter hash" do
      @parameters.should_receive(:merge!).twice.and_return(@merged_parameters) end
    it "should sort the parameter hash" do
      @parameters.should_receive(:sort).and_return(@merged_parameters.sort) end
    it "should call #signature" do
      @bconn.should_receive(:signature).and_return(mock("String")) end
    it "should call #post_request" do
      @bconn.should_receive(:post_request).and_return(mock("Net::HTTP::Post")) end
    it "should return a Net::HTTP::Post object" do
      @bconn.build_query(@function, @parameters).should be_kind_of(Net::HTTP::Post) end
  end
  
  context "Building a Query - #post_request" do
    before(:each) do
      setup_auth; setup_parameters; 
      @mock_post = mock("Net::HTTP::Post")
      Net::HTTP::Post.stub!(:new).and_return(@mock_post)
      @mock_post.stub!(:form_data=)
      @bconn = new_bebo_connection
      @sorted_parameters = @parameters.sort.collect{|x| x.join("=")}
    end
    after(:each) do
      @bconn.post_request(@sorted_parameters) end
      
    it "should call Net::HTTP::Post" do
      Net::HTTP::Post.should_receive(:new).with(BEBO_REMOTE_SERVER_PATH).and_return(@mock_post) end
    it "should set #form_data on the return Net::HTTP::Post object with parameters joined by '&'" do
      @mock_post.should_receive(:form_data=).with(@sorted_parameters) end
  end
  
  context "Calling a Bebo API method" do
    before(:each) { @bconn = new_bebo_connection }
    after(:each) { @bconn.call_bebo_method("users.getLoggedInUser") }
    it "should respond to #call_bebo_method" do
      @bconn.should respond_to(:call_bebo_method) end
    it "should call JSON.parse" do
      JSON.should_receive(:parse).and_return(mock("String")) end
  end
  
end