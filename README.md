# PleasanterExportImage

Pleasanterのバイナリーデータ（ロゴ、添付、コメントや内容などに張り付けたデータ）は初期設定ではデータベースに保存されます。 
 
本プログラムはデータベースに保存されたバイナリデータをファイルに保存するプログラムです。
 
# 設定
本プログラムは使用するライブラリを簡単にする為にODBCを使用しています。 

## ODBCの設定
使用するデータベースのODBCドライバのインストールと接続設定を事前に行ってください。 
PostgreSQLの場合は、使用環境によりpg_hba.confの修正が必要になる場合が有ります。 
SQL-SERVERの場合は使用するプロトコルにTCP/IPを有効にする必要になる場合が有ります。

## データフォルダの準備
データを作成するフォルダは予め作成してください。 

## パラメータの変更
| 変数名 | 設定する値 | サンプル (SQL-SERVERの場合)|
|-|-|-|
|$DNS|ODBC名|MSSQL_Pleasanter|
|$HNM|ホスト名|localhost|
|$DB|データベース名|Implem.Pleasanter|
|$UID|ユーザー名|sa|
|$PWD|パスワード||
|$Folder|データを作成するフォルダ|C:\web\data|

## 使用するSQLコマンドの設定
52行目あたり 
SQL-SERVERの場合
```
$odbcCmd.CommandText = $MSCMD
```
PostgreSQLの場合
```
$odbcCmd.CommandText = $PGCMD
```

# 最後に
無事バイナリデータを作成した後はデータベースのバイナリデータを消去します。 
データを削除する為の一般的なSQLです。 
ツールな使用するデータベースに合わせて変更してください。
UPDATE Binaries SET Bin=NULL, Thumbnail=NULL, Icon=NULL
