# -*- coding: utf-8 -*-
# requrie 'date'
Module.new do
  def self.boot
    plugin = Plugin::create(:fav_timeline)
    plugin.add_event(:boot) do |service|
      Plugin.call(:setting_tab_regist, main, 'ふぁぼ')
    end
    plugin.add_event(:update) do |service, message|
      if UserConfig[:auto_fav] || UserConfig[:auto_rt]
        if UserConfig[:fav_users]
          UserConfig[:fav_users].split(',').each do |user|
            users( user.strip, message )
          end
        end
        if UserConfig[:fav_keywords]
          UserConfig[:fav_keywords].split(',').each do |key|
            keywords( key.strip, message )
          end
        end
      end
    end
  end

  def self.users( target, msg )
    if !msg.empty?
      msg.each do |m|
        user = m.idname
        if user == target
          # ふぁぼるよ
          unless( m.favorite? || m[:retweet] )
            m.favorite(true) if UserConfig[:auto_fav]
          end
          # リツイートするよ
          unless m[:retweet]
            m.retweet if UserConfig[:auto_rt]
          end
        end
      end
    end
  end

  def self.keywords( key, msg )
    if !msg.empty?
      msg.each do |m|
        # p m.to_s
        if /#{key}/u =~ m.to_s
          m.favorite(true) if UserConfig[:auto_fav] && !m.favorite?
          m.retweet if UserConfig[:auto_rt] && !m[:retweet]
        end
      end
    end
  end

  def self.main
    box = Gtk::VBox.new(false)
    fav_u = Mtk.group("ふぁぼるよ",
                      Mtk.boolean(:auto_fav, "じどうふぁぼ"),
                      Mtk.boolean(:auto_rt, "じどうりついーと"),
                      Mtk.input(:fav_users,"ふぁぼるゆーざ"),
                      Mtk.input(:fav_keywords, "きーわーど"))
    # fav_a = Mtk.boolean(:auto_fav, "じどうふぁぼ")
    # fav_r = Mtk.boolean(:auto_rt, "じどうりついーと")
    box.closeup(fav_u)
  end

  boot
end
