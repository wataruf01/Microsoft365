#実行アカウント
$adminUserName  = "XXX@XXX.onmicrosoft.com"
$securePassword = "XXX" | ConvertTo-SecureString -AsPlainText -Force
Add-PowerAppsAccount -Username $adminUserName -Password $securePassword

#対象のDLPポリシーを指定
$dlpPolicy = Get-DlpPolicy -PolicyName "XXXX-XXXX-XXX-XXXX-XXXX"

$connectors = @()

$businessDataGroup = $DLPPolicy.connectorGroups | where classification -EQ "Confidential"
foreach($connector in $businessDataGroup.connectors)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Policy -Value $DLPPolicy.displayName
    $obj | Add-Member -MemberType NoteProperty -Name Group  -Value "BusinessDataGroup"
    $obj | Add-Member -MemberType NoteProperty -Name Name   -Value $connector.name
    $obj | Add-Member -MemberType NoteProperty -Name ID     -Value $connector.id
    $obj | Add-Member -MemberType NoteProperty -Name Type   -Value $connector.type
    $connectors += $obj
}

$nonBusinessDataGroup = $DLPPolicy.connectorGroups | where classification -EQ "General"
foreach($connector in $nonBusinessDataGroup.connectors)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Policy -Value $DLPPolicy.displayName
    $obj | Add-Member -MemberType NoteProperty -Name Group  -Value "NonBusinessDataGroup"
    $obj | Add-Member -MemberType NoteProperty -Name Name   -Value $connector.name
    $obj | Add-Member -MemberType NoteProperty -Name ID     -Value $connector.id
    $obj | Add-Member -MemberType NoteProperty -Name Type   -Value $connector.type
    $connectors += $obj
}

$blockedGroup = $DLPPolicy.connectorGroups | where classification -EQ "Blocked"
foreach($connector in $blockedGroup.connectors)
{
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Policy -Value $DLPPolicy.displayName
    $obj | Add-Member -MemberType NoteProperty -Name Group  -Value "BlockedGroup"
    $obj | Add-Member -MemberType NoteProperty -Name Name   -Value $connector.name
    $obj | Add-Member -MemberType NoteProperty -Name ID     -Value $connector.id
    $obj | Add-Member -MemberType NoteProperty -Name Type   -Value $connector.type
    $connectors += $obj
}

$connectors | Export-Csv -Path .\DLPPolicy.csv -Encoding UTF8 -NoTypeInformation
