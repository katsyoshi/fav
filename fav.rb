# -*- coding: utf-8 -*-
# requrie 'date'
miquire :core, "serialthread"
Plugin::create(:fav_timeline) do
  prev = UserConfig[:fav_users]

  on_update do |service, message|
    if UserConfig[:auto_fav] || UserConfig[:auto_rt]
      if UserConfig[:fav_users]
        UserConfig[:fav_users].split(',').each do |user|
          users( user.strip, message )
        end
      end
      if UserConfig[:fav_keywords]
        UserConfig[:fav_keywords].split(',').each do |key|
          users( "toshi_a", message ) if key.strip == "."
          keywords( key.strip, message ) if key.strip != "."
        end
      end
      if UserConfig[:fav_sources]
        UserConfig[:fav_sources].split(',').each do |key|
          source( key.strip, message )
        end
      end
    end
  end

  on_period do
    if UserConfig[:auto_fav] && UserConfig[:fav_users]
      prev = UserConfig[:fav_users] if notify_friends(prev)
    end
  end

  # ついーとしたゆーざをふぁぼふぁぼするよ
  def users( target, msg )
    if !msg.empty?
      msg.each do |m|
        user = m.idname
        if user == target
          rt = m[:retweet]
          fav = m.favorite?
          delay_fav(m)
        end
      end
    end
  end

  # ついーとにきーわーどが含まれたらふぁぼふぁぼするよ
  def keywords( key, msg )
    if !msg.empty?
      msg.each do |m|
        if /#{key}/u =~ m.to_s
          delay_fav(m)
        end
      end
    end
  end

  # ついったーくらいあんとでふぁぼふぁぼするよ
  def source( key, msg )
    if !msg.empty?
      msg.each do |m|
        if /#{key}/u =~ m[:source] && !m.from_me?
          delay_fav(m)
        end
      end
    end
  end

  # 遅延させてふぁぼるよ
  def delay_fav(message)
    sec = rand(UserConfig[:fav_lazy].to_i)
    Reserver.new(sec.to_i) do
      if UserConfig[:auto_fav]
        message.favorite(true) if !message.favorite? && !message[:retweet]
      end
      if UserConfig[:auto_rt]
        message.retweet if !message[:retweet]
      end
    end
    return sec
  end

  # 通知するお
  def notify_friends(prev)
    if UserConfig[:notify_favrb]
      if prev != UserConfig[:fav_users]
        str = prev
        UserConfig[:fav_users].split(/,/).each do |u|
          user = u.strip
          str = str.sub(/#{user}/, '')
          if /#{user}/ !~ prev
            Service.services.first.update(:message => "せっと @#{user}")
          end
        end
        str.split(/,/).each do|u|
          user = u.strip
          if !user.empty?
            Service.services.first.update(:message => "あんせっと @#{user}")
          end
        end
        true
      end
    end
  end

  settings 'ふぁぼ' do
    boolean "じどうふぁぼ", :auto_fav
    boolean "じどうりついーと", :auto_rt
    boolean "つうち", :notify_favrb
    input "ふぁぼるゆーざ", :fav_users
    input "きーわーど", :fav_keywords
    input "そーす", :fav_sources
    adjustment "ちえん時間", :fav_lazy, 0, 3600
  end
end
