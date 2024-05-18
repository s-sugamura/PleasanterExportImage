Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$DNS = "<ODBC名>"
$HNM = "localhost"
$DB = "Implem.Pleasanter"
$UID = "sa"
$PWD = "<パスワード>"

# ライブラリ読み込み
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Data")

# DB接続
$connectionString = "DSN=$DNS;host=$HNM;database=$DB;uid=$UID;pwd=$PWD;"
$odbcCon = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$odbcCon.Open()

# コマンドオブジェクト作成
$odbcCmd = New-Object System.Data.Odbc.OdbcCommand
$odbcCmd.Connection = $odbcCon

$Folder = "C:\web\data"
New-Item ($Folder + "\Attachments") -ItemType Directory -Force
New-Item ($Folder + "\Images") -ItemType Directory -Force
New-Item ($Folder + "\SiteImage") -ItemType Directory -Force
New-Item ($Folder + "\TenantImage") -ItemType Directory -Force

$page = 0
$limit = 100
while( 1 -eq 1 ){
    $page = $page + 1
    $offset = ($page - 1) * $limit
    $rows = (($page - 1) * $limit) + 1
    $rowe = $page * $limit

    # コマンド実行（SELECT）
    #PostgreSQL
    $PGCMD = "SELECT ""TenantId"",""ReferenceId"",""BinaryId"",""BinaryType"",""Title"",""FileName"",""Extension"",""Size"",""ContentType"",""Guid"",""Bin"",""Thumbnail"",""Icon"""
    $PGCMD = $PGCMD + " FROM ""Binaries"""
    $PGCMD = $PGCMD + " LIMIT $limit OFFSET $offset"
    #SQL-Server
    $MSCMD = "SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY [BinaryId]) AS rownum,[TenantId],[ReferenceId],[BinaryId],[BinaryType],[Title],[FileName],[Extension],[Size],[ContentType],[Guid],[Bin],[Thumbnail],[Icon]"
    $MSCMD = $MSCMD + " FROM [Binaries]) AS t"
    $MSCMD = $MSCMD + " WHERE rownum BETWEEN $rows AND $rowe ORDER BY rownum"

    #
    $odbcCmd.CommandText = $MSCMD
    $odbcReader = $odbcCmd.ExecuteReader()
    $cnt = 0
    while ($odbcReader.Read()) {
        $cnt = $cnt + 1
        $BinType = $odbcReader["BinaryType"].ToString()
        $RefId = $odbcReader["ReferenceId"].ToString()
        $BinId = $odbcReader["BinaryId"].ToString()
        $Guid = $odbcReader["Guid"].ToString()
        $FileName = $odbcReader["FileName"].ToString()
        $FileExt = $odbcReader["Extension"].ToString()
	$Size = $odbcReader["Size"].ToString()
        Write-Host $BinId $BinType $Size
	If( $odbcReader["Bin"].ToString().Length -ne 0 ) {
            If( $BinType -eq "SiteImage" ) {
                [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $RefId + "_Regular.png", $odbcReader["Bin"]);
                [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $RefId + "_Icon.png", $odbcReader["Icon"]);
                [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $RefId + "_Thumbnail.png", $odbcReader["Thumbnail"]);
            } ElseIf( $BinType -eq "TenantImage" ) {
                [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $BinId + "_Logo.png", $odbcReader["Bin"]);
            } ElseIf( $BinType -eq "Attachments" ) {
                [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $Guid, $odbcReader["Bin"]);
            } ElseIf( $BinType -eq "Images" ) {
               [System.IO.File]::WriteAllBytes($Folder + "\" + $BinType + "\" + $Guid, $odbcReader["Bin"]);
            }
	}
    }
    $odbcReader.Dispose()
    if( $cnt -eq 0 ) {
        break
    }
}
# コマンドオブジェクト破棄
$odbcCmd.Dispose()

# DB切断
$odbcCon.Close()
$odbcCon.Dispose()

#SELECT * FROM Binaries
#UPDATE Binaries SET Bin = NULL, Thumbnail=NULL, Icon=NULL
