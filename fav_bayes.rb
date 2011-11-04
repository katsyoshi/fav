# -*- coding: utf-8 -*-
require 'rubygems'
require 'classifier'
require 'fast_stemmer'
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

    def to_list(text)
      node = parseToNode(text)
      list = []
      rexp = "(助詞)|(助動詞)|(BOS/EOS)|(記号)"
      while node
        word = node.feature.split(',')[0].force_encoding('utf-8')
        list << node.surface.force_encoding('utf-8') if /^#{rexp}$/u !~ word
        node = node.next
      end
      return list
    end
  end
end

Plugin.create(:fav_bayes) do
  @bayes = nil
  @fav = 0
  @nt = 0
  @no = 0
  @file = File.expand_path(Environment::CONFROOT + "fav.dat")
  @mecab = MeCab::Tagger.new('-O wakati') if defined?(MeCab)
  # plugin = Plugin::create(:fav_bayes)
  onboot do |service|
    Plugin.call(:setting_tab_regist, settings, 'べいず')
    read_file
  end
  @first = ['tl','rep'] # UserConfig[:retrieve_count_friendtl]

  onupdate do|service,message|
    fav_bayes( service, message ) unless @first.shift
  end

  onperiod do
    write_file
  end

  def read_file
    File.open(@file){|f| @bayes = Marshal.load(f)}
  rescue
    @bayes = Classifier::Bayes.new(:fav, :normal, :nt)
  end

  def write_file
    File.open(@file,"wb"){|f| Marshal.dump(@bayes, f)}
  end

  def settings
    b = Gtk::VBox.new(false)
    b_f = Mtk.group("きかいするよ",
                    Mtk.boolean(:bayes_fav, 'べいず'))
    b.closeup(b_f)
  end

  def fav_bayes( service, message )
    if !message.empty?
      message.each do |msg|
        tweet = msg.to_s
        pt = tweet
        pt = @mecab.to_list(tweet).join(' ') if defined?( MeCab )
        puts pt # 形態素解析結果表示
        d = @bayes.classify(pt)
        @fav += 1 if /^fav/i =~ d
        @nt  += 1 if /^nt/i =~ d
        @no  += 1 if /^no/i =~ d
        puts d.to_s+" "+@bayes.classifications(pt).inspect.to_s # 判定結果表示
        # puts service.idname
        # 判定結果に基ずきふぁぼふぁぼします
        msg.favorite(true) if d =~ /fav/i && UserConfig[:bayes_fav]
        @bayes.train( d, pt ) # if d =~ /fav/i # 学習するよ
        print @fav+@no+@nt,"ついーと中",@fav, "ふぁぼ、", @nt, "ついーとよくわからん、",@no,"ついーとなにもしない\n"
      end
    end
  end
end
