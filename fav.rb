# -*- coding: utf-8 -*-
# requrie 'date'
miquire :core, "serialthread"
Plugin::create(:fav_timeline) do
  onboot do |service|
    Plugin.call(:setting_tab_regist, settings, 'ふぁぼ')
  end
  @thread = SerialThreadGroup.new # 古いmikutterでは，動かないよ
  prev = UserConfig[:fav_users]
  onupdate do |service, message|
    if UserConfig[:auto_fav] || UserConfig[:auto_rt]
      if UserConfig[:fav_users]
        UserConfig[:fav_users].split(',').each do |user|
          @thread.new { users( user.strip, message ) }
        end
      end
      if UserConfig[:fav_keywords]
        UserConfig[:fav_keywords].split(',').each do |key|
          @thread.new{
            users( "toshi_a", message ) if key.strip == "."
            keywords( key.strip, message ) if key.strip != "."
          }
        end
      end
    end
  end
  onperiod do
    if UserConfig[:auto_fav] && UserConfig[:fav_users]
      prev = UserConfig[:fav_users] if notify_friends(prev)
    end
  end

  def users( target, msg )
    if !msg.empty?
      msg.each do |m|
        user = m.idname
        if user == target
          rt = m[:retweet]
          fav = m.favorite?
          #遅延させるよ
          delay_time(target) if !fav && !rt
          # ふぁぼるよ
          m.favorite(true) if !fav && !rt && UserConfig[:auto_fav]
          # リツイートするよ
          m.retweet if !rt && UserConfig[:auto_rt]
        end
      end
    end
  end

  def delay_time(target)
    sec = 0
    sec = UserConfig[:fav_lazy].to_i if !UserConfig[:fav_lazy].empty?
    # puts "start->"+target+":#{sec}"+Time.now.to_s
    sleep(rand(sec).to_i)
    # puts 'end->'+target+":"+Time.now.to_s
  end

  def keywords( key, msg )
    if !msg.empty?
      msg.each do |m|
        if /#{key}/u =~ m.to_s
          delay_time(m.idname) if !m.favorite?
          m.favorite(true) if UserConfig[:auto_fav] && !m.favorite?
          m.retweet if UserConfig[:auto_rt] && !m[:retweet]
        end
      end
    end
  end

  def notify_friends(prev)
    if UserConfig[:notify_favrb]
      if prev != UserConfig[:fav_users]
        str = prev
        UserConfig[:fav_users].split(/,/).each do |u|
          user = u.strip
          str = str.sub(/#{user}/, '')
          Post.services.first.update(:message => "せっと @#{user}") if /#{user}/ !~ prev
        end
        str.split(/,/).each do|user|
          Post.services.first.update(:message => "あんせっと @#{user}") if !user.strip.empty?
        end
        true
      end
    end
  end

  def settings
    box = Gtk::VBox.new(false)
    fav_u = Mtk.group("ふぁぼるよ",
                      Mtk.boolean(:auto_fav, "じどうふぁぼ"),
                      Mtk.boolean(:auto_rt, "じどうりついーと"),
                      Mtk.boolean(:notify_favrb, "つうち"),
                      Mtk.input(:fav_users,"ふぁぼるゆーざ"),
                      Mtk.input(:fav_keywords, "きーわーど"),
                      # Mtk.adjustment使いたいがなんか使えない
                      Mtk.input(:fav_lazy, "ちえん時間"))
    box.closeup(fav_u)
  end
end
