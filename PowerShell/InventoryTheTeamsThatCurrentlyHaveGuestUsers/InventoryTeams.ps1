#-------------------------------------------------
#実行アカウント
#-------------------------------------------------
$user     = "XXX@XXX.onmicrosoft.com"
$password = "XXX" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential($user,$password)

#-------------------------------------------------
#変数の設定
#-------------------------------------------------
#出力するCSVのパス
$now = (Get-Date).ToString("yyyyMMdd_HHmm")
$CSVFilePath = ".\InventoryTeams_" + $now + ".csv"

#-------------------------------------------------
#主処理
#-------------------------------------------------
#Exchange Onlineに接続する
Connect-ExchangeOnline -Credential $credential

#Microsoft Teamsに接続する
Connect-MicrosoftTeams -Credential $credential

#Microsoft365グループをすべて取得する
$groups = Get-UnifiedGroup -ResultSize Unlimited

#チームをすべて取得する
$teams = Get-Team

#ゲストユーザーがいるチームをCSVに出力する
foreach($team in $teams)
{
    #チームに紐づくMicrosoft365グループを取得する
    $targetGroup =  $groups | where ExternalDirectoryObjectId -EQ $team.GroupId

    #外部共有がオフの場合はスキップする
    if($targetGroup.AllowAddGuests -eq $false)
    {
        continue
    }

    #ゲストユーザーがいない場合はスキップする
    $teamUser = Get-TeamUser -GroupId $team.GroupId
    $guests = $teamUser | Where-Object "Role" -EQ "guest" | Select-Object -ExpandProperty User
    if($guests.Count -ne 0)
    {
        continue
    }

    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name DisplayName        -Value $team.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $targetGroup.PrimarySmtpAddress
    $obj | Add-Member -MemberType NoteProperty -Name GroupID            -Value $team.GroupId

    $obj | Export-Csv -Path $CSVFilePath -Encoding UTF8 -NoTypeInformation -Append -force
}
