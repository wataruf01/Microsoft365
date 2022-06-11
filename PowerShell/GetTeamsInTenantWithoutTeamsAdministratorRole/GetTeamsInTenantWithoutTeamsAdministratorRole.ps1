#-------------------------------------------------
#認証情報
#-------------------------------------------------
$user = "****@****.com"
$pass = "****" | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user,$pass) 

#-------------------------------------------------
#前準備：チームに紐づくグループをすべて取得
#-------------------------------------------------
Connect-AzureAD -Credential $credential

$allTeams = Get-AzureADMSGroup -Filter "groupTypes/any(c:c eq 'Unified')" -All $true

#-------------------------------------------------
#主処理：グループの情報をCSVに出力する
#-------------------------------------------------
$outputFile = ".\output.csv"

foreach($team in $allTeams)
{
    #チームの情報をCSVに出力
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name DisplayName     -Value $team.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name Mail            -Value $team.Mail
    $obj | Add-Member -MemberType NoteProperty -Name CreatedDateTime -Value $team.CreatedDateTime
    $obj | Add-Member -MemberType NoteProperty -Name Visibility      -Value $team.Visibility

    $obj | Export-Csv -Path $outputFile -Encoding UTF8 -NoTypeInformation -Append
}
