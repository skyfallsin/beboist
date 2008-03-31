module BeboControllerExtensions
  
  def initialize_bebo_connection
    @connection = BeboAPI::Base.connection = BeboConnection.new(params[:fb_sig_session_key])
  end
  
  def ensure_bebo_application_is_installed
    params[:fb_sig_added] == "1"
  end
  
  def find_bebo_user
    @user = User.find_or_create_by_bebo_id(params[:fb_sig_user]) 
  end
  
  def url_for_with_bebo_rewrite(opts={}, *parameters_for_method_reference)
    if within_bebo_environment?
      opts.merge!(:only_path => true) if opts.is_a?(Hash)
      path = url_for_without_bebo_rewrite(opts, *parameters_for_method_reference)
      # callback = @connection.auth_data["callback_path"]
      "http://apps.bebo.com#{path}"
    else
      url_for_without_bebo_rewrite(opts)
    end
  end
  
  def redirect_to_with_bebo_rewrite(options={}, *args)
    path = url_for(options, *args)
    if within_bebo_environment?
      render :text => "<sn:redirect url='#{path}' />"
    else
      redirect_to_without_bebo_rewrite(options, *args)
    end
  end
  
  # Bebo allows people into your app without them having to add it first. Including this call into your
  # controllers as a before_filter ensures that they have to add the app first
  # Warning: Maybe be prone to breakage on API changes
  def reject_unadded_users
    if !ensure_bebo_application_is_installed
      new_params = {"apikey" => @connection.auth_data["api_key"], "next" => url_for(params)}
      signature = @connection.signature(new_params)
      render :text =>
        "<sn:redirect url='http://bebo.com/c/apps/add?ApiKey=#{@connection.auth_data["api_key"]}&next=#{new_params[:next]}&sig=#{signature}'/>" and return
    end
  end
  
  def self.included(base)
    base.class_eval do 
      alias_method_chain :url_for, :bebo_rewrite
      alias_method_chain :redirect_to, :bebo_rewrite 
    end
    base.before_filter(:initialize_bebo_connection)
  end

  def within_bebo_environment?
    params.has_key?(:fb_sig_in_canvas)
  end

end