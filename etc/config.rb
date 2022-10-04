#!/bin/env ruby

## 一般設定

# VOICEVOX Engineのホスト名orIPアドレス、ポート番号を指定する配列 (複数設定すると並列で変換を実行)
VOICEVOX_ENGINE = [ "127.0.0.1:50021" ]

# HTTPのタイムアウト(秒)
HTTP_TIMEOUT = 300

# 出力ファイル名のデフォルト値
OUTFILENAME = "output"


## 出力される音声に関する設定

# SpeakerIDと声の対応
#  0: 四国めたん(あまあま)    10: 雨晴はう(ノーマル)    20: モチノ・キョウコ(ノーマル)  30: No.7(アナウンス)
#  1: ずんだもん(あまあま)    11: 玄野武宏(ノーマル)    21: 剣崎雌雄(ノーマル)          31: No.7(読み聞かせ)
#  2: 四国めたん(ノーマル)    12: 白上虎太郎(ふつう)    22: ずんだもん(ささやき)        32: 白上虎太郎(わーい)
#  3: ずんだもん(ノーマル)    13: 青山龍星(ノーマル)    23: WhiteCUL(ノーマル)          33: 白上虎太郎(びくびく)
#  4: 四国めたん(セクシー)    14: 冥鳴ひまり(ノーマル)  24: WhiteCUL(たのしい)          34: 白上虎太郎(おこ)
#  5: ずんだもん(セクシー)    15: 九州そら(あまあま)    25: Whitecul(かなしい)          35: 白上虎太郎(びえーん)
#  6: 四国めたん(ツンツン)    16: 九州そら(ノーマル)    26: Whitecul(びえーん)
#  7: ずんだもん(ツンツン)    17: 九州そら(セクシー)    27: 後鬼(人間ver.)
#  8: 春日部つむぎ(ノーマル)  18: 九州そら(ツンツン)    28: 後鬼(ぬいぐるみver.)
#  9: 波音リツ(ノーマル)      19: 九州そら(ささやき)    29: No.7(ノーマル)

# 声の種類のデフォルト値 (SpeakerIDを指定)
SPEAKER = "0"

# 音声種別にランダムが指定されたとき、この配列からSpeakerIDがランダムで選択される
RANDOM_SPEAKER = [0,1,2,3,4,5,6,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,13,13,13,13,14,14,14,14,15,16,17,18,19,20,20,20,20,21,21,21,21,22,23,24,25,26,27,27,28,28,29,29,30,31,32,33,34,35]

# 声ごとのスピード、ピッチ、イントネーション、ボリュームのデフォルト補正値
#  スピード　　　　　：話速にこの値を掛けて補正　　　　　　　0.50～1.50 程度の範囲を推奨
#  ピッチ　　　　　　：ピッチにこの値を足して補正　　　　　　0.10～0.10 程度の範囲を推奨
#  イントネーション　：イントネーションにこの値を掛けて補正　0.00～2.00 程度の範囲を推奨
#  ボリューム　　　　：音量にこの値を掛けて補正　　　　　　　0.10～2.00 程度の範囲を推奨
CORRECT_MATRIX = [
  # スピード      ピッチ  イントネーション  ボリューム
  [  1.00,        0.00,        1.00,        1.00  ],  #  0:四国めたん(あまあま)
  [  1.00,        0.00,        1.00,        1.00  ],  #  1:ずんだもん(あまあま)
  [  1.00,        0.00,        1.00,        1.00  ],  #  2:四国めたん(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  #  3:ずんだもん(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  #  4:四国めたん(セクシー)
  [  1.00,        0.00,        1.00,        1.00  ],  #  5:ずんだもん(セクシー)
  [  1.00,        0.00,        1.00,        1.00  ],  #  6:四国めたん(ツンツン)
  [  1.00,        0.00,        1.00,        1.00  ],  #  7:ずんだもん(ツンツン)
  [  1.00,        0.00,        1.00,        1.00  ],  #  8:春日部つむぎ(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  #  9:波音リツ(ノーマル)
  # スピード      ピッチ  イントネーション  ボリューム
  [  1.00,        0.00,        1.00,        1.00  ],  # 10:雨晴はう(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 11:玄野武宏(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 12:白上虎太郎(ふつう)
  [  1.00,        0.00,        1.00,        1.00  ],  # 13:青山龍星(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 14:冥鳴ひまり(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 15:九州そら(あまあま)
  [  1.00,        0.00,        1.00,        1.00  ],  # 16:九州そら(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 17:九州そら(セクシー)
  [  1.00,        0.00,        1.00,        1.00  ],  # 18:九州そら(ツンツン)
  [  1.00,        0.00,        1.00,        1.00  ],  # 19:九州そら(ささやき)
  # スピード      ピッチ  イントネーション  ボリューム
  [  1.00,        0.00,        1.00,        1.00  ],  # 20:モチノ・キョウコ(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 21:剣崎雌雄(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 22:ずんだもん(ささやき)
  [  1.00,        0.00,        1.00,        1.00  ],  # 23:WhiteCUL(ノーマル)
  [  1.00,        0.00,        1.00,        1.00  ],  # 24:WhiteCUL(たのしい)
  [  1.00,        0.00,        1.00,        1.00  ],  # 25:Whitecul(かなしい)
  [  1.00,        0.00,        1.00,        1.00  ],  # 26:Whitecul(びえーん)
  [  1.00,        0.00,        1.00,        1.00  ],  # 27:後鬼(人間ver.)
  [  1.00,        0.00,        1.00,        1.00  ],  # 28:後鬼(ぬいぐるみver.)
  [  1.00,        0.00,        1.00,        1.00  ],  # 29:No.7(ノーマル)
  # スピード      ピッチ  イントネーション  ボリューム
  [  1.00,        0.00,        1.00,        1.00  ],  # 30:No.7(アナウンス)
  [  1.00,        0.00,        1.00,        1.00  ],  # 31:No.7(読み聞かせ)
  [  1.00,        0.00,        1.00,        1.00  ],  # 32:白上虎太郎(わーい)
  [  1.00,        0.00,        1.00,        1.00  ],  # 33:白上虎太郎(びくびく)
  [  1.00,        0.00,        1.00,        1.00  ],  # 34:白上虎太郎(おこ)
  [  1.00,        0.00,        1.00,        1.00  ],  # 35:白上虎太郎(びえーん)
]

# 最初の無音時間のデフォルト値 (秒)
FIRST_SILENT_TIME = 0.0

# 最後の無音時間のデフォルト値 (秒)
LAST_SILENT_TIME = 0.0

# 文章間で無音にする間隔のデフォルト値 (秒)
INTERVAL = 0.8

# 段落間で無音にする間隔のデフォルト値 (秒)
PARAGRAPH_INTERVAL = 2.0


## 音声再生に関する設定

# 音声再生に使用するコマンド (aplay,sox)
PLAY_CMD = "aplay"

# vvttsコマンドがaplayコマンド実行時に使用するデバイス名 (XRDP_PULSE_* 環境変数がないか、--no-rdp が指定された場合に使用される)
APLAY_VVTTS_DEVICE = "sysdefault"

# seqread.rbがaplayコマンド使用時に使用するデバイス名 (「sysdefault」「plughw:1,0」などを指定する)
APLAY_SEQREAD_DEVICE = "sysdefault"

# vvttsコマンドがsox (playコマンド) 実行時に使用するデバイス名 (XRDP_PULSE_* 環境変数がないか、--no-rdp が指定された場合に使用される)
SOX_VVTTS_DEVICE = "hw:0,0"

# seqread.rbがsox (playコマンド) 実行時に使用するデバイス名
SOX_SEQREAD_DEVICE = "hw:0,0"


## 音声ファイルのmp3化に関する設定

# soxのmp3変換オプション (-C オプションでビットレート (kbps) と品質 (0-9 小さいほど高品質) を指定)
SOX_OPT1 = "-C 128.2"
SOX_OPT2 = "channels 1 rate 44.1k"

# ffmpegのmp3変換オプション
FFMPEG_OPT = "-vn -ar 44100 -b:a 128k -c:a libmp3lame -f mp3 -y"
