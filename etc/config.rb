#!/bin/env ruby

## 一般設定

# VOICEVOX Engineのホスト名orIPアドレス、ポート番号を指定する配列 (複数設定すると並列で変換を実行)
VOICEVOX_ENGINE = [ "127.0.0.1:50021" ]

# HTTPのタイムアウト(秒)
HTTP_TIMEOUT = 300

# 出力ファイル名のデフォルト値
OUTFILENAME = "output"


## 出力される音声に関する設定

# 声の種類のデフォルト値 (0-14のいずれかを指定)
SPEAKER = "0"

# 声の種類によって音量にこの値を掛けて補正できる
VOLUME_CORRECT = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

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

