# F-RevoCRM 6.5

F-RevoCRM は、世界中で活用されている VtigerCRM をベースに、
日本の企業文化に合わせてシンキングリードが独自のカスタマイズを行った、
フリー＆オープンな高機能CRMアプリケーションです。

## 動作要件
* Apache 2.4以上
* PHP 5.4以上（7.x非対応）
* MySQL 5.5以上

## インストール方法（概要）
以下、F-RevoCRMのインストール方法になります。

* F-RevoCRM6.5のインストール方法はそのまま読み進めてください。
* F-RevoCRM6.2patch1からのバージョンアップはインストール方法の後に記載があります。
* F-RevoCRM6.5のパッチ適用方法については各パッチ付属のREADMEを参照してください。

### 前提条件
データベース名などを「frevocrm」としてインストールすることを前提に記載します。

### 1. Apache, PHP, MySQLのインストール

事前にそれぞれをインストールしておいてください。

***注意点1**

MySQLのSTRICT_TRANS_TABLESを無効にしてください。
```
# 下記手順は設定例

vi /etc/my.cnf

# 以下の行をコメントアウト
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

# mysqlを再起動
service mysqld restart
```

***注意点2**

php.iniにてdate.timezoneを設定してください。

### 2. データベースの作成

mysqlコマンド等で、以下のSQLを実行します。

```
create database frevocrm default character set utf8 collate utf8_unicode_ci;
```

* 個別のユーザーとパスワードを割り当てる場合は下記コマンドを参考にしてください。  
```
create user frevocrm identified by 'password';  
grant all on frevocrm.* to frevocrm@localhost;  
set password for frevocrm@localhost=password('password');
```
* ここではわかりやすいようにパスワードは「password」にしていますが、実際は推測されづらい文字列を推奨します。

### 3. F-RevoCRMのZIPファイルを解凍、設置

ApacheのDocumentRoot以下に解凍したディレクトリ毎、あるいはファイルを置いて下さい。
ここでは仮に/var/www/frevocrmに設置したものをとして進めます。

### 4. 初期設定

3.で設置したF-RevoCRMのURLを開きます。
* http://xxx.xxx.xxx.xxx/frevocrm

画面に従って初期設定を完了させてください。


## バージョンアップ方法
F-RevoCRM 6.2 patch1 を F-RevoCRM 6.5 にバージョンアップする手順になります。

### 前提条件
* F-RevoCRM 6.2 patch1 であること
* ソースコードの修正がされていないこと
* F-RevoCRM 6.5のインストール済み環境があること

### 1. バックアップの取得
F-RevoCRMのデータベース、ファイルを全てバックアップを取得します。

### 2. マイグレーションツールの取得
VtigerCRMのマイグレーションツールを取得します。

* [Migration Software (6.2.0 to 6.3.0)](https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.3.0/Core%20Product/vtigercrm-620-630-patch.zip/download)
* [Migration Software (6.3.0 to 6.4.0)](https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.4.0/Core%20Product/vtigercrm-630-640-patch.zip/download)
* [Migration Software (6.4.0 to 6.5.0)](https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.5.0/Core%20Product/vtigercrm-640-650-patch.zip/download)

### 3. 6.2.0 to 6.3.0 の実行
vtigercrm-620-630-patch.zip を解凍して中身の「migrate」と「vtiger6.zip」を
F-RevoCRMのルートディレクトリ（インストールディレクトリ）にコピーします。
※上書き確認が出た場合、上書きしてください。

ブラウザでF-RevoCRMのmigrateディレクトリを開きます。
http://xxx.xxx.xxx.xxx/frevocrm/migrate

画面の指示に従ってマイグレーションを行います。

### 4. 6.3.0 to 6.4.0 の実行
vtigercrm-630-640-patch.zip を解凍して中身の「migrate」と「vtiger6.zip」を
F-RevoCRMのルートディレクトリ（インストールディレクトリ）にコピーします。
※上書き確認が出た場合、上書きしてください。

ブラウザでF-RevoCRMのmigrateディレクトリを開きます。
http://xxx.xxx.xxx.xxx/frevocrm/migrate

画面の指示に従ってマイグレーションを行います。

### 5. 6.4.0 to 6.5.0 の実行
vtigercrm-640-650-patch.zip を解凍して中身の「migrate」と「vtiger6.zip」を
F-RevoCRMのルートディレクトリ（インストールディレクトリ）にコピーします。
※上書き確認が出た場合、上書きしてください。

ブラウザでF-RevoCRMのmigrateディレクトリを開きます。
http://xxx.xxx.xxx.xxx/frevocrm/migrate

画面の指示に従ってマイグレーションを行います。

### 6. プログラムファイルの置き換え
1. F-RevoCRMのディレクトリ全体を別名に置き換えます。
```
# コマンド例
mv frevocrm frevocrm.20170118
```
2. F-RevoCRM 6.5 インストール直後のファイルをもともとのF-RevoCRMのディレクトリとしてコピーします。
```
# コマンド例
cp -r frevocrm65 frevocrm
```
3. F-RevoCRMの設定ファイル(config.*, *.properties, *tabdata.php)をコピーします。
```
# コマンド例
cp frevocrm.20170118/config.* frevocrm/
cp frevocrm.20170118/*.properties frevocrm/
cp frevocrm.20170118/*tabdata.php frevocrm/
```
4.F-RevoCRMのドキュメントファイルをコピーします。
```
# コマンド例
cp -r frevocrm.20170118/storage/* frevocrm/storage/
```

7. 動作確認
  F-RevoCRMのログインや業務に関わる動作を確認してください。

8. 作業ディレクトリの削除
6.で別名に退避したディレクトリを削除してください。
```
# コマンド例
rm -r frevocrm.20170118
```

## F-RevoCRM6.5の変更点

* Vtiger6.3～6.5までの修正点
  - http://trac.vtiger.com/cgi-bin/trac.cgi/query?status=closed&group=resolution&milestone=6.3.0
  - http://trac.vtiger.com/cgi-bin/trac.cgi/query?status=closed&group=resolution&milestone=6.4.0
  - http://code.vtiger.com/vtiger/vtigercrm/milestones/1

* F-RevoCRM独自の修正点
  - CSVダウンロード時に日本語名が文字化けする
  - ドキュメントに日本語ファイル名のファイルを添付すると文字が欠けることがある
  - CSVインポート時に数値項目にカンマが含まれている場合、数字が欠ける
  - 顧客担当者の敬称（Mr.,Ms.など）の表記を削除
  - 金額の入力中に自動でカンマが入るようにする
  - ワークフローのTOアドレスに `Taro Yamada <taro@exmaple.com>` の表記が使えない
  - スマートフォン向けにスタイルを少し調整

## F-RevoCRM6.5 patch1の変更点
* 不具合修正
  - 前のページに戻れない不具合を修正
  - カレンダーにスケジュールが表示されない不具合を修正
  - IMEがONの状態で数値を入力すると数字が増殖する不具合を修正
  - PDF出力の際に日本語が出力ができるように修正
  - 検索していないにも関わらず、検索結果の件数が表示される不具合を修正
  - 日付型データをエクスポートした際にUTF0:00基準で出力される不具合を修正

## F-RevoCRM6.5 patch2の変更点
* 機能改善
  - フィールドの編集からラベル名を変更できるように改善（多言語は不可）
  - 管理者権限を持っている場合は「すべて」が付くフィルタが編集できるように改善
  - 予定表を見やすいように改善
  - 予定表で予定をマウスオーバーした際に「場所」項目が表示されるように改善
  - IEの互換表示モードにならないようにmetaタグを追加
* 不具合修正
  - vtigercrm.logが利用PHPバージョン等よって1世代しか残らない不具合を修正
  - 複数選択可能な選択肢の名称を変更した際に、対象の選択肢が選択されているデータの名称が変わるように修正
  - IEでドキュメントのファイルをダウンロードすると文字化けしないように修正
  - IEで金額を入力した後、他の入力欄にカーソルが当たらなくなる現象を修正
  - ワークフローでメール送信時に「担当者」を本文等に挿入してもメールに記載されない問題を修正
  - レポートで日付型の項目を出力すると「-」しか出力されない問題を修正
  - 各モジュールのエクスポートで大量のデータを出力した際にエラーになる問題を修正
  - ユーザ管理で「アクティブ」「非アクティブ」の切り替えやアルファベット検索が正しく動作しない問題を修正

## F-RevoCRM6.5 patch3の変更点
* 機能改善
  - スマートフォンからアクセスした際のレイアウトを大幅に改善
  - 一覧画面のアルファベット検索を削除
* 不具合修正
  - ワークフローからメール送信できない不具合を修正
  - エクスポート時にファイル名が文字化けする不具合を修正
  - ユーザーを関連させた項目を作成した際にインポート/エクスポートが正しく動作しない問題を修正

以上

