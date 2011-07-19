# -*- coding: utf-8 -*-
require 'rubygems'
require 'classifier'
# require 'stemmer'
require_if_exist 'MeCab'

miquire :core, 'twitter_api'
miquire :core, 'environment'

class String
  alias_method :original_stem, :stem
  def stem
    self.original_stem.force_encoding(self.encoding)
  end
end

if defined?(MeCab)
  class MeCab::Tagger
    alias_method :original_parse, :parse
    def parse(text)
      original_parse(text).force_encoding(text.encoding)
    end
  end
end
Module.new do
  def self.boot
    @bayes = nil
    @fav = 'fav'
    @no = 'no'
    @file = File.expand_path(Environment::CONFROOT + "fav.dat")
    @mecab = MeCab::Tagger.new('-O wakati') if defined? MeCab
    plugin = Plugin::create(:fav_bayes)
    plugin.add_event(:boot) do |service|
      Plugin.call(:setting_tab_regist, main, 'べいず')
    end
    read_file
    plugin.add_event(:update) do |service, message|
      fav_bayes( service, message )
      write_file
    end
    plugin.add_event(:period){|s, m| write_file}
  end

  def self.read_file
    File.open(@file){|f| @bayes = Marshal.load(f)}
  rescue
    @bayes = Classifier::Bayes.new(@fav, @no)
  end

  def self.write_file
    File.open(@file,"wb"){|f| Marshal.dump(@bayes, f)}
  end

  def self.main
    b = Gtk::VBox.new(false)
    b_f = Mtk.group("きかいするよ",
                    Mtk.boolean(:bayes_fav, 'べいず'))
    b.closeup(b_f)
  end

  def self.fav_bayes( service, message )
    if !message.empty?
      message.each do |msg|
        tweet = msg.to_s
        pt = tweet
        pt = @mecab.parse(tweet) if defined? MeCab
        d = @bayes.classify(pt)
        puts pt # 形態素解析結果表示
        puts d.to_s+" "+@bayes.classifications(pt).inspect.to_s # 判定結果表示
        # puts service.idname
        # 判定結果に基ずきふぁぼふぁぼします
        msg.favorite(true) if d =~ /fav/i && UserConfig[:bayes_fav]
        @bayes.train( d, pt ) # 学習するよ
      end
    end
  end
  boot
end
