# Thank you Chad Fowler: http://facebooker.rubyforge.org/svn/trunk/facebooker/lib/facebooker/rails/facebook_url_rewriting.rb

module ::ActionController
  class AbstractRequest                         
    def relative_url_root                       
      "#{ENV["BEBO_CALLBACK_PATH"]}"
    end                                         
  end
  
  class UrlRewriter
    # RESERVED_OPTIONS << :canvas
    
    def link_to_canvas?(params, options)
      @request.parameters["fb_sig_in_canvas"] == "1" ||  @request.parameters[:fb_sig_in_canvas] == "1" 
    end

    def rewrite_url_with_beboist(*args)
      options = args.first.is_a?(Hash) ? args.first : args.last
      is_link_to_canvas = link_to_canvas?(@request.request_parameters, options)
      options[:skip_relative_url_root] ||= !is_link_to_canvas
      if is_link_to_canvas && !options.has_key?(:host)
        options[:host] = "apps.bebo.com"
      end 
      options.delete(:canvas)
      rewrite_url_without_beboist(*args)
    end

    alias_method_chain :rewrite_url, :beboist
  end
end