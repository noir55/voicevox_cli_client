#!/bin/env ruby

class CMUDICT

  require 'json'

  VOWELS={
    'AA'=> '',
    'AH'=> '',
    'AE'=> 'a',
    'AO'=> 'o',
    'AW'=> 'a',
    'AY'=> 'a',
    'EH'=> 'e',
    'ER'=> 'a',
    'EY'=> 'e',
    'IH'=> 'i',
    'IY'=> 'i',
    'OW'=> 'o',
    'OY'=> 'o',
    'UH'=> 'u',
    'UW'=> 'u',
  }

  ENG2KANA={
    'B'=>{'a'=>'バ','i'=>'ビ','u'=>'ブ','e'=>'ベ','o'=>'ボ',''=>'ブ'},
    'CH'=>{'a'=>'チャ','i'=>'チ','u'=>'チュ','e'=>'チェ','o'=>'チョ',''=>'チ'},
    'D'=>{'a'=>'ダ','i'=>'ディ','u'=>'ドゥ','e'=>'デ','o'=>'ド',''=>'ド'},
    'DH'=>{'a'=>'ザ','i'=>'ジ','u'=>'ズ','e'=>'ゼ','o'=>'ゾ',''=>'ズ'},
    'F'=>{'a'=>'ファ','i'=>'フィ','u'=>'フ','e'=>'フェ','o'=>'フォ',''=>'フ'},
    'G'=>{'a'=>'ガ','i'=>'ギ','u'=>'グ','e'=>'ゲ','o'=>'ゴ',''=>'グ'},
    'HH'=>{'a'=>'ハ','i'=>'ヒ','u'=>'フ','e'=>'ヘ','o'=>'ホ',''=>'フ'},
    'JH'=>{'a'=>'ジャ','i'=>'ジ','u'=>'ジュ','e'=>'ジェ','o'=>'ジョ',''=>'ジ'},
    'K'=>{'a'=>'カ','i'=>'キ','u'=>'ク','e'=>'ケ','o'=>'コ',''=>'ク'},
    'L'=>{'a'=>'ラ','i'=>'リ','u'=>'ル','e'=>'レ','o'=>'ロ',''=>'ル'},
    'M'=>{'a'=>'マ','i'=>'ミ','u'=>'ム','e'=>'メ','o'=>'モ',''=>'ム'},
    'N'=>{'a'=>'ナ','i'=>'ニ','u'=>'ヌ','e'=>'ネ','o'=>'ノ',''=>'ン'},
    'NG'=>{'a'=>'ンガ','i'=>'ンギ','u'=>'ング','e'=>'ンゲ','o'=>'ンゴ',''=>'ング'},
    'P'=>{'a'=>'パ','i'=>'ピ','u'=>'プ','e'=>'ペ','o'=>'ポ',''=>'プ'},
    'R'=>{'a'=>'ラ','i'=>'リ','u'=>'ル','e'=>'レ','o'=>'ロ',''=>'ー'},
    'S'=>{'a'=>'サ','i'=>'シ','u'=>'ス','e'=>'セ','o'=>'ソ',''=>'ス'},
    'SH'=>{'a'=>'シャ','i'=>'シ','u'=>'シュ','e'=>'シェ','o'=>'ショ',''=>'シュ'},
    'T'=>{'a'=>'タ','i'=>'ティ','u'=>'チュ','e'=>'テ','o'=>'ト',''=>'ト'},
    'TH'=>{'a'=>'サ','i'=>'シ','u'=>'シュ','e'=>'セ','o'=>'ソ',''=>'ス'},
    'V'=>{'a'=>'バ','i'=>'ビ','u'=>'ブ','e'=>'ベ','o'=>'ボ',''=>'ブ'},
    'W'=>{'a'=>'ワ','i'=>'ウィ','u'=>'ウ','e'=>'ウェ','o'=>'ウォ',''=>'ウ'},
    'Y'=>{'a'=>'ア','i'=>'','u'=>'ュ','e'=>'エ','o'=>'ョ',''=>'イ'},
    'BOS_Y'=>{'a'=>'ヤ','i'=>'イ','u'=>'ユ','e'=>'イエ','o'=>'ヨ',''=>'イ'},
    'Z'=>{'a'=>'ザ','i'=>'ジ','u'=>'ズ','e'=>'ゼ','o'=>'ゾ',''=>'ズ'},
    'ZH'=>{'a'=>'ジャ','i'=>'ジ','u'=>'ジュ','e'=>'ジェ','o'=>'ジョ',''=>'ジュ'},
    'T_S'=>{'a'=>'ツァ','i'=>'ツィ','u'=>'ツ','e'=>'ツェ','o'=>'ツォ',''=>'ツ'},
  }

  def find_vowel(text, pos, length)
    p = (pos + 0.5) / length
    lengthoftext = text.length
    distance_list = Array.new
    vowel_list = Array.new
    text.chars.each_with_index {|s,i|
      if ['a','i','u','e','o'].include?(s) then
        vowel_list << s
        distance_list << (p - (i + 0.5) / lengthoftext).abs
      end
    }
    if distance_list.length == 0 then
      return 'a'
    end
    v = vowel_list[ distance_list.index(distance_list.min) ]
    if v == 'u' then
      v = 'a'
    end
    return v
  end

  # クラスを初期化する関数
  def initialize

    @eng_kana_dic = Hash.new

    # キャッシュファイルがあり、キャッシュファイルのほうが新しい場合キャッシュファイルから読み込む
    if File.exist?("#{__dir__}/cmudict.cache") and 
       File.mtime("#{__dir__}/cmudict.cache") > File.mtime("#{__dir__}/cmudict.dict") then

      open("#{__dir__}/cmudict.cache"){|f|
        @eng_kana_dic = JSON.load(f)
      }

    # キャッシュファイルがなければ、辞書ファイルから読み込んでキャッシュファイルを作成
    else

      open("#{__dir__}/cmudict.dict", "r"){|f|

        f.each_line{|line|

          word = line.split(/ +/)[0]
          p = line.split(/ +/)[1..-1].join(" ").gsub(/[0-9]/,"")

          #print "word=#{word} p=#{p}\n"
          yomi = ""
          #word, p = line.split("\t")
          if word =~ /^[0-9a-zA-Z'_\.\-]+$/ then
            # 単語は全て小文字に変換
            word = word.downcase
            # 発音記号は配列に入れる
            sound_list = p.split()
            sound_list = ['BOS'] + sound_list + ['EOS'] + ['']
            sound_list.each_with_index{|value, index|
              if index == 0 then
                next
              end
              s = sound_list[index]
              s_prev = sound_list[index-1]
              s_next = sound_list[index+1]
              s_next2 = sound_list[index+2]
              if s_prev == 'BOS' and s == 'Y' then
                sound_list[index] = 'BOS_Y'
                s = 'BOS_Y'
              end
              if ENG2KANA.key?(s) and not VOWELS.key?(s_next) then
                if s_next == 'Y' then
                  yomi += ENG2KANA[s]['i'][0]
                elsif s == 'D' and s_next == 'Z' then
                  next
                elsif s == 'T' and s_next == 'S' then
                  sound_list[index+1] = 'T_S'
                  next
                elsif s == 'NG' and ['K','G'].include?(s_next) then
                  yomi += ENG2KANA[s][''][0]
                elsif ['EH','EY','IH','IY'].include?(s_prev) and s == 'R' then
                  yomi += 'アー'
                else
                  yomi += ENG2KANA[s]['']
                end
              elsif VOWELS.key?(s) then
                # 先頭が「AA」で綴りの最初が「au」の場合、母音を「o」にする
                if ['BOS'].include?(s_prev) and ['AA'].include?(s) and word[0..1] == "au" then
                  v = 'o'
                #「AA」「AH」の場合は母音を調べる
                elsif ['AA','AH'].include?(s) then
                  v = find_vowel(word, index-1, sound_list.length-3)
                else
                  v = VOWELS[s]
                end
                if ENG2KANA.key?(s_prev) then
                  yomi += ENG2KANA[s_prev][v]
                  # 「ッ」を追加するルール1
                  if ['B','D','F','G','K','L','P','R','T','V','HH','JH'].include?(s_prev) and
                     ['AA','AE','AH','IH','UH','EH','OH','AO'].include?(s) and
                     ['D','G','K','P','T','CH','SH'].include?(s_next) and
                     ['EOS'].include?(s_next2) then
                    yomi  += "ッ"
                  end
                  # 「ッ」を追加するルール2
                  if ['K'].include?(s_prev) and
                     ['AH'].include?(s) and
                     ['SH'].include?(s_next) and
                     ['AH'].include?(s_next2) then
                    yomi  += "ッ"
                  # 「ョ」を追加するルール
                  end
                  if ['SH','ZH'].include?(s_prev) and
                     ['AH'].include?(s) and
                     ['N'].include?(s_next) then
                    yomi += "ョ"
                    #「ョ」が連続したら削除
                    yomi.sub!('ョョ','ョ')
                  end
                else
                  if ['AY','EY','OY'].include?(s_prev) and not ['AA','AH'].include?(s) then
                    yomi += {'a' => 'ヤ', 'i' => 'イ', 'u' => 'ユ', 'e' => 'エ', 'o' => 'ヨ'}[v]
                  elsif ['AW','UW'].include?(s_prev) then
                    yomi += {'a' => 'ワ', 'i' => 'ウィ', 'u' => 'ウ', 'e' => 'ウェ', 'o' => 'ウォ'}[v]
                  elsif ['ER'].include?(s_prev) then
                    yomi += {'a' => 'ラ', 'i' => 'リ', 'u' => 'ル', 'e' => 'レ', 'o' => 'ロ'}[v]
                  else
                    yomi += {'a' => 'ア', 'i' => 'イ', 'u' => 'ウ', 'e' => 'エ', 'o' => 'オ'}[v]
                  end
                end
                if ['AY','EY','OY'].include?(s) then
                  yomi += 'イ'
                end
                if not VOWELS.key?(s_next) then
                  # 「OW」は最後にないときは伸ばす
                  if ['OW'].include?(s) and (not ['EOS'].include?(s_next)) then
                    yomi += 'ー'
                  elsif ['ER','IY','UW'].include?(s) then
                    yomi += 'ー'
                  elsif ['AW'].include?(s) then
                    yomi += 'ウ'
                  end
                end
                # 先頭に「AA D」「AO D」の場合「ー」を追加する
                if ['BOS'].include?(s_prev) and
                   ['AA', 'AO'].include?(s) and
                   ['D'].include?(s_next) and
                   word[0..1] == "au" then
                  yomi += "ー"
                end
              end
            }
	    #print "#{word}\t#{yomi}\n"
            @eng_kana_dic[word] = yomi      
          end
        } #each_line
      } #open

      # ディレクトリに書き込み権限があればcmudict.cacheに書き込み
      if  File.writable?("#{__dir__}") then
        File.open("#{__dir__}/cmudict.cache", "w"){|f|
          JSON.dump(@eng_kana_dic,f)
        }
      end

    end

  end # initialize

  def word2kana(word)
    tword = word.tr('ａ-ｚＡ-Ｚ','a-zA-Z')
    tword = tword.downcase
    if @eng_kana_dic.key?(tword) then
      return @eng_kana_dic[tword]
    else
      return word
    end
  end

end #class

CMUDICT.new
