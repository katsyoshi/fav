# -*- coding: utf-8 -*-
miquire :core, 'serialthread'
Plugin.create(:favbuzz) do
  @thread = SerialThreadGroup.new
  onupdate do |s,m|
    @thread.new{favbuzz(m)}
  end

  def favbuzz(message)
    if !message.first.nil?
      m = message.first
      sec = rand(30)
      if m.to_s.size % 3 == 0
        sleep(sec)
        m.favorite(true)
      end
      if m.to_s.size % 5 == 0 && !m.from_me?
        sleep(sec)
        Post.services.first.update(:message => "★",
                                   :replyto => message.first)
      end
    end
  end
end

