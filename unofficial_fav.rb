# -*- coding: utf-8 -*-
Module.new do
  Plugin.create(:unofficial_fav).add_event_filter(:command) do |menu|
    menu[:unofficial_fav] = {
      :slug => :unofficial_fav,
      :name => 'unofficial fav',
      :condition => lambda{ |m| m.message.repliable? },
      :exec => lambda{|m| 
        Post.services.first.update(:message => "@#{m.message.user.idname} ★", 
                                   :replyto => m.message) },
      :visible => true,
      :role => :message }
    [menu]
  end
end
