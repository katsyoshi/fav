# -*- coding: utf-8 -*-
# requrie 'date'
Module.new do
  def self.boot
    plugin = Plugin::create(:fav_timeline)
    plugin.add_event(:boot) do |service|
      Plugin.call(:setting_tab_regist, main, 'ふぁぼ')
    end
    plugin.add_event(:update) do |service, message|
      if UserConfig[:fav_users] && ( UserConfig[:auto_fav] ||
                                     UserConfig[:auto_rt] )
        UserConfig[:fav_users].split(',').each do |user|
          fav( user.strip, message )
        end
      end
    end
  end

  def self.fav( target, msg )
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

  def self.main
    box = Gtk::VBox.new(false)
    fav_u = Mtk.group("ふぁぼるよ",
                      Mtk.boolean(:auto_fav, "じどうふぁぼ"),
                      Mtk.boolean(:auto_rt, "じどうりついーと"),
                      Mtk.input(:fav_users,"ふぁぼるゆーざ"))
    # fav_a = Mtk.boolean(:auto_fav, "じどうふぁぼ")
    # fav_r = Mtk.boolean(:auto_rt, "じどうりついーと")
    box.closeup(fav_u)
  end

  boot
end
