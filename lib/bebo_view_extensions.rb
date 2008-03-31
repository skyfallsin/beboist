module BeboViewExtensions  
  module AssetTagHelper
    def self.included(base)
      base.class_eval do
        alias_method_chain :compute_public_path, :bebo_rewrite
        alias_method_chain :path_to_image, :bebo_rewrite
      end
    end
    
    def compute_public_path_with_bebo_rewrite(*args)
      path = compute_public_path_without_bebo_rewrite(*args)
      # the UrlWriter code adds the relative_url_root to the path, so lets remove that for image paths 
      path.gsub(/#{@controller.request.relative_url_root}/,'')
    end
    
    def path_to_image_with_bebo_rewrite(*args)
      path = path_to_image_without_bebo_rewrite(*args)
      path = "#{request.protocol}#{request.host_with_port}#{path}" unless path.include?("http://")
      path
    end
  end
end