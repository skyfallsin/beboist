class BeboUsers < BeboAPI::Base
  register_method :get_info, :uids => [Numeric, String, Array], :fields => [String, Array]
  register_method :is_app_added
  register_method :get_logged_in_user
end

class BeboProfile < BeboAPI::Base
  register_method :set_SNML, :uid => [Numeric, String], :markup => String
  register_method :get_SNML, :uid => [Numeric, String]
end

class BeboFeed < BeboAPI::Base
  feed_opts = {:title => String, :body => String,
               :image_1 => String, :image_1_link => String,
               :image_2 => String, :image_2_link => String,
               :image_3 => String, :image_3_link => String,
               :image_4 => String, :image_4_link => String}

  register_method :publish_action_of_user, feed_opts.merge(:REQUIRED => :title)
  register_method :publish_story_to_user,  feed_opts.merge(:REQUIRED => :title)
end

class BeboFriends < BeboAPI::Base
  register_method :are_friends, :uids1 => Array, :uids2 => Array
  register_method :get
  register_method :get_app_users 
end

class BeboGroups < BeboAPI::Base
  register_method :get, :uid => [Numeric, String], :gids => Array, :REQUIRED => []
  register_method :get_members, :gid => [Numeric, String]
end

class BeboNotifications < BeboAPI::Base
  register_method :get
  register_method :send, :to_ids => [Numeric, String, Array], :notification => String, :email => String,
                         :REQUIRED => [:to_ids, :notification]
  register_method :send_request, :to_ids => [Numeric, Array], :type => String, :content => String,
                                 :invite => [TrueClass, FalseClass]
end

class BeboPhotos < BeboAPI::Base
  register_method :create_album, :name => String
  register_method :get, :aid => [Numeric, String], :pids => [Numeric, String, Array], :REQUIRED => :any_one_key
  register_method :get_albums, :uid => [Numeric, String]
end