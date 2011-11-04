# -*- coding: utf-8 -*-
# Module.new do
Plugin.create(:unofficial_fav) do
  filter_command do |menu|
    menu[:unofficial_fav] = {
      :slug => :unofficial_fav,
      :name => '非公式ふぁぼ',
      :condition => lambda{ |m| m.message.repliable? },
      :exec => lambda{|m| unofficial(m) },
      :visible => true,
      :role => :message }
    [menu]
  end

  def unofficial(msg)
    Reserver.new(0){
      t = 1
      # 40.times{|t| # このコメントを外すと
      Post.primary_service.update(:message => "@#{msg.message.user.idname} #{"★"*t}",
                                    :replyto => msg.message)
      # } # このコメントを外すと
    }
  end
end
