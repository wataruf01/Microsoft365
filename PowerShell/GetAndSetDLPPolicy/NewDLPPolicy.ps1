#実行アカウント
$adminUserName  = "XXX@XXX.onmicrosoft.com"
$securePassword = "XXX" | ConvertTo-SecureString -AsPlainText -Force
Add-PowerAppsAccount -Username $adminUserName -Password $securePassword

#ポリシーの名前
$newDLPPolicyName = "XXXX"

#既定のグループ
$defaultConnectorsClassification = "General"

#入力用CSVのファイルパス
$inputCSVFilePath = ".\DLPPolicy.csv"

#DLPポリシーを作成する
$newDLPPolicy = New-DlpPolicy -DisplayName $newDLPPolicyName -EnvironmentType "AllEnvironments"
$newDLPPolicy.defaultConnectorsClassification = $defaultConnectorsClassificatio

#入力用CSVからコネクタの情報をインポートする
$csv = Import-Csv -Path $inputCSVFilePath -Encoding UTF8 | select Group,Name,ID,Type
$allConnectors = $csv | Group-Object -Property Group

#CSVから取得したコネクタ情報をグループごとにグループ化する
$BusinessDataConnectors    = $allConnectors | Where Name -EQ "BusinessDataGroup" 
$NonBusinessDataConnectors = $allConnectors | Where Name -EQ "NonBusinessDataGroup"  
$BlockedConnectors         = $allConnectors | Where Name -EQ "BlockedGroup"  

#「ビジネス」グループに割り当てるコネクタを定義する
$BusinessDataConnectorsGroup = `
[PSCustomObject]@{
    classification = "Confidential"
    connectors     = $BusinessDataConnectors.Group | Select Name,ID,Type
}

#「非ビジネス」グループに割り当てるコネクタを定義する
$NonBusinessDataConnectorsGroup = `
[PSCustomObject]@{
    classification = "General"
    connectors     = $NonBusinessDataConnectors.Group | Select Name,ID,Type
}

#「ブロック済み」グループに割り当てるコネクタを定義する
$BlockedConnectorsGroup = 
[PSCustomObject]@{
    classification = "Blocked"
    connectors     = $BlockedConnectors.Group | Select Name,ID,Type
}

#定義したコネクタ情報をDLPポリシーにセットする
$allConnectorGroups = @()
$allConnectorGroups += $BlockedConnectorsGroup
$allConnectorGroups += $BusinessDataConnectorsGroup
$allConnectorGroups += $NonBusinessDataConnectorsGroup
$newDLPPolicy.connectorGroups = $AllConnectorGroups

#DLPポリシーの設定を更新する
Set-DlpPolicy -PolicyName $newDLPPolicy.name -UpdatedPolicy $newDLPPolicy
