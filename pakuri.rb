# -*- coding: utf-8 -*-
Plugin.create(:pakuri) do
  filter_command do |menu|
    menu[:pakuri] = {
      :slug => :pakuri,
      :name => "ぱくり",
      :condition => lambda{|m| m.message.repliable?},
      :exec => lambda{|m| pakuri(m.message) },
      :visible => true,
      :role => :message
    }
    [menu]
  end
  def pakuri(message)
    name=message.idname
    message.favorite(true)
    message.retweet
    str=message.to_s
    Post.primary_service.update(:message => str)
    Post.primary_service.update(:message => "@#{name} http://twitter.com/#!/#{name}/status/#{message.id}をパクリました")
  end
end
