Givalia
=============

About
------
Givaliaは非同期式メッセージキューのRuby実装です。

キューにセットされたメッセージ読み出しを行うWorkerは任意のサーバに配置することができます。またWorkerがメッセージを受信した際に処理を行う内容はRubyスクリプトで実装することが可能です。


Usage (server & worker)
------
Gem files:

 * eventmachine

Givalia server:

    $ cd bin
    $ ./givalia_server -p [server port] -w [worker server port]

Givalia worker:

    $ cd bin
    $ ./givalia_worker -m [Givalia server host name] -w [Givalia worker server port] -n [Worker name]

 * -h でUsageが表示されます。
 * サーバはメッセージ受信用に1ポート, ワーカー間の通信用に1ポート使用します。
  * 標準では以下のポートが利用されます。
   * メッセージ受信用(-p): 12322
   * ワーカー間通信用(-w): 12323
 * Givaliaのサーバおよび、ワーカーをデーモンとして常駐させる場合は、-d オプションを付与することでデーモン化することができます。
  * -dオプションを付与してサーバおよび、ワーカーを起動した場合、起動直後にデーモンへ割り当てられたPIDが標準出力されます。
 * 現状、サーバが行うキューは揮発します。Givaliaサーバが停止した場合、キューされていたメッセージは破棄されます。

Que Commands
-------
メッセージキューに格納するにはクライアントからサーバーに対して定義されたコマンドを実行します。
Givaliaは以下のコマンドをメッセージコマンドとして備えます。

### enq
 * 概要
  * メッセージキューにメッセージを登録します。

 * パラメータ一覧
  * time
  * module
  * params
  * key
  * target_worker

### stat
 * 概要
  * メッセージキューに格納したメッセージの状態を確認します。
 * パラメータ一覧
  * key

### cancel
 * 概要
  * メッセージキューに格納したメッセージを破棄します。
 * パラメータ一覧
  * key

### ext
 * 概要
  * メッセージキューに格納したメッセージの実行時間を延長します。
 * パラメータ一覧
  * key
  * time



Example
-------
10秒後にワーカーに配置した"Sample"モジュールを実行させ、パラメータとして"parameter sample"という文字列を渡す場合は、以下の様な記述で実装ることができます。

以下の例の場合、Givaliaサーバにメッセージを通知した後、10秒後にワーカーが稼働するサーバ上で標準出力に"Run job sample"という文字列と、メッセージを通知する際に付与した文字列が標準出力に表示されます。


Module sample:

    # ~/module/Sample.rb
    require File.dirname(__FILE__) + "/../lib/workmodule"

    class Sample < Givalia::WorkModule
        def process 
            p "Run job sample"
            p @params
        end
    end


Enque sample:

    client = Givalia::Client.new("127.0.0.1", 12322)
    res = client.enq({:time=>10, :module=>"Sample", :params=>"parameter sample"})


Conifguration
----------

Plan
----------
 * メッセージキューの永続化


Features and Changes
----------
 * 2012-4-15
  * メッセージ登録時のワーカー選択機能実装

Helping Out
----------
 * -

Thanks
------
hika69, [@hika69](http://twitter.com/hika69) - REMP project 

Author
------
hideack, [d.hatena.ne.jp/hideack](http://d.hatena.ne.jp/hideack/), [@hideack](http://twitter.com/hideack)

