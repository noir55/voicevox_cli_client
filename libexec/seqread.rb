#!/bin/env ruby

require 'socket'
require 'open3'
require 'fileutils'
require 'json'
require 'optparse'


#------
# 設定
#------

# データ受け取り用ソケットのパス
SOCKFILE = "#{__dir__}/../var/run/seqread.sock"

# vvttsコマンドのパス
VVTTSCMD = "#{__dir__}/../bin/vvtts"

# 設定ファイルを読み込む
if File.exist?("#{__dir__}/../etc/config.rb")
  require_relative '../etc/config.rb'
else
  STDOUT.print "設定ファイル \"#{__dir__}/../etc/config.rb\" が見つかりません"
  exit 1
end


#----------
# 関数定義
#----------

# デバッグメッセージを表示する関数
def debug_print(message)
  if @debug_flag == 1 then
    STDERR.print "Debug: #{message}\n"
  end
end

# 文字列を音声に変換するスレッドで実行される処理
def make_wavdata(jsondata)
  begin
    # JSONをハッシュに変換
    msgdata=JSON.parse(jsondata)
    # 投稿されたメッセージを取り出す
    msg_text = msgdata["message"]
    # 再生コマンドにパイプで音声データを渡して実行
    o, e, s = Open3.capture3("#{VVTTSCMD} --stdout", :stdin_data=>msg_text)
    # 標準出力のwavデータを返す
    return o
  # 何かエラーが発生したら
  rescue => e
    # エラーが発生したら nil を返す
    STDERR.print "テキスト音声変換スレッドでエラーが発生しました (e=\"#{e.message}\")\n"
    STDERR.print "VVTTSCMD=#{VVTTSCMD}\n" 
    return nil
  end
end


# 音声データを再生するスレッドで実行される処理
def play_wav(wavdata)
  begin
    # aplayコマンドで再生する場合
    if PLAY_CMD == "aplay" then
      play_cmd = "aplay -D #{APLAY_DEVICE}"
    # sox(play)コマンドで再生する場合
    elsif PLAY_CMD == "sox" then
      # 環境変数「AUDIODEV」で再生するデバイスを指定
      ENV['AUDIODEV'] = SOX_DEVICE
      # 再生コマンド
      play_cmd = "play -"
    end
    # 再生コマンドにパイプで音声データを渡して実行
    Open3.capture3(play_cmd, :stdin_data=>wavdata)
  rescue => e
    # エラーが発生したら nil を返す
    STDERR.print "音声再生スレッドでエラーが発生しました (e=\"#{e.message}\")\n"
    return nil
  end
end


#----------
# 処理開始
#----------

# オプションの処理
opt = OptionParser.new
opt.on('--debug', 'デバッグメッセージを出力します') {|v| @debug_flag = 1 }
opt.parse!(ARGV)

# データを受け取る用のソケットを作成して待ち受ける
unix_dgram = Socket.new(:UNIX, :DGRAM)
File.unlink(SOCKFILE) if File.exist? SOCKFILE
unix_dgram.bind Socket.sockaddr_un(SOCKFILE)
FileUtils.chmod(0600, SOCKFILE)

# データ(JSON)を格納する配列
json_array = Array.new

# 音声データを格納する配列
voice_array = Array.new

# データ読み出しスレッド変数を初期化
read_thread = nil

# 変換スレッド変数を初期化
conv_thread = nil

# 再生スレッド変数の初期化
play_thread = nil

# 無限ループで繰り返す
catch :loop do
  while true do

    # 1秒待つ
    sleep 1

    # データ読み出しスレッドが実行されていなかったら
    if read_thread.nil? then
      # 読み出しスレッドを実行
      read_thread = Thread.new { unix_dgram.recv(4096) }
      # デバッグ用
      debug_print("start read thread (J=#{json_array.length} V=#{voice_array.length})")
    # データ読み出しスレッドが終了していたら
    elsif read_thread.status == false then
      # 正常終了で戻り値があれば
      if (not read_thread.nil?) and (not read_thread.value.nil?) then
        # json_arrayに格納
        json_array << read_thread.value
      end
      # 読み出しスレッドを停止
      read_thread = nil
      # デバッグ用
      debug_print("stop read thread (J=#{json_array.length} V=#{voice_array.length})")
    end


    # 変換スレッドが実行されておらず、変換すべきテキストがあったら
    if conv_thread.nil? and json_array.length > 0 then
      # データを取り出して新たな変換スレッドを実行
      data = json_array.shift
      conv_thread = Thread.new { make_wavdata(data) }
      # デバッグ用
      debug_print("start conv thread (J=#{json_array.length} V=#{voice_array.length})")
    # 変換スレッドが終了していたら
    elsif (not conv_thread.nil?) and conv_thread.status == false then
      # 正常終了で戻り値があれば
      if (not conv_thread.value.nil?) then
        # voice_arrayに格納
        voice_array << conv_thread.value
      end
      # 変換スレッドを停止
      conv_thread = nil
      # デバッグ用
      debug_print("stop conv thread (J=#{json_array.length} V=#{voice_array.length})")
    end


    # 再生スレッドが実行されておらず、再生すべき音声があったら
    if play_thread.nil? and voice_array.length > 0 then
      # データを取り出して新たな変換スレッドを実行
      voicedata = voice_array.shift
      play_thread = Thread.new { play_wav(voicedata) }
      # デバッグ用
      debug_print("start new play thread (J=#{json_array.length} V=#{voice_array.length})")
    # 再生スレッドが終了していたら
    elsif (not play_thread.nil?) and play_thread.status == false then
      # 再生スレッドを停止
      play_thread = nil
      # デバッグ用
      debug_print("stop play thread (J=#{json_array.length} V=#{voice_array.length})")
    end

  end
end

