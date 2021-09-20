$adminUserName  = "XXX@XXX.onmicrosoft.com"
$securePassword = "XXX" | ConvertTo-SecureString -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($adminUserName, $securePassword)

Connect-AzureAD -Credential $credentials
Connect-MicrosoftTeams -Credential $credentials

#全ユーザーを取得
$azureADAllUser= Get-AzureADUser -All $true

#チームのメンバーをCSVに出力
$teamMembers =  Get-TeamUser -GroupId "XXXX-XXXX-XXX-XXXX-XXXX"
$members = @()
foreach($member in $teamMembers)
{
    $currentUser = $azureADAllUser | where ObjectID -EQ $member.UserId

    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $currentUser.DisplayName
    $obj | Add-Member -MemberType NoteProperty -Name Mail        -Value $currentUser.UserPrincipalName
    $obj | Add-Member -MemberType NoteProperty -Name Department  -Value $currentUser.Department
    $obj | Add-Member -MemberType NoteProperty -Name JobTitle    -Value $currentUser.JobTitle
    $members += $obj
}

$members | Export-Csv -Path .\TeamMember.csv -Encoding UTF8 -NoTypeInformation
