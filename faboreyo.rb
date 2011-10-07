# -*- coding: utf-8 -*-
Plugin::create(:faboreyo) do
  filter_command do|menu|
    menu[:faboreyo] = {
      :slug => :faboreyo,
      :name => 'ふぁぼれよ',
      :condition => lambda{ |m| m.message.repliable? },
      :exec => lambda{|m|
        Post.services.first.update(:message => "@#{m.message.user.idname}ふぁぼれよ")},
      :visible => true,
      :role => :message }
    [menu]
  end
end
