#認証情報
$user = "xxx@xxx.onmicrosoft.com"
$pass = "xxx" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $pass)

#環境に接続
Connect-PnPOnline "https://xxx.sharepoint.com" -Credentials $credential
Connect-AzureAD -Credential $credential

#テナント内のフローを取得
$environments = @(Get-PnPPowerPlatformEnvironment)

$flows = @()

foreach($environment in $environments)
{
    $flows += Get-PnPFlow -Environment $environment -AsAdmin
}

#すべてのAzureADユーザーを取得
$allUsers = Get-AzureADUser -All $true

#出力するCSVファイルのパスを定義
$outputFile = ".\output.csv"

foreach($flow in $flows)
{
    #作成者情報を取得
    $creator = $allUsers | where ObjectId -EQ $flow.Properties.Creator.ObjectId

    #配列を作成
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name 名前 　　　　　　-Value $flow.Properties.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name 環境 　　　　　　-Value $flow.Properties.EnvironmentDetails.Name
    $obj | Add-Member -MemberType NoteProperty -Name フローID　　　　 -Value $flow.Name
    $obj | Add-Member -MemberType NoteProperty -Name 作成者アドレス　 -Value $creator.Mail
    $obj | Add-Member -MemberType NoteProperty -Name 作成者名　　　　 -Value $creator.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name 作成日時 　　　　-Value $flow.Properties.CreatedTime
    $obj | Add-Member -MemberType NoteProperty -Name ステータス 　　　-Value $flow.Properties.State
    $obj | Add-Member -MemberType NoteProperty -Name アクションの個数 -Value $flow.Properties.DefinitionSummary.Actions.Count

    #CSVに出力
    $obj | Export-Csv -Path $outputFile -Encoding UTF8 -NoTypeInformation -Append
}
