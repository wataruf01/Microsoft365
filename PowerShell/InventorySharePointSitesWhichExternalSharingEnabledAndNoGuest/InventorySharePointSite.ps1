#-------------------------------------------------
#実行アカウント
#-------------------------------------------------
#$user     = "XXX@XXX.onmicrosoft.com"
#$password = "XXX" | ConvertTo-SecureString -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential($user,$password)

#-------------------------------------------------
#変数の設定
#-------------------------------------------------
#出力するCSVのパス
$now = (Get-Date).ToString("yyyyMMdd_HHmm")
$CSVFilePath = ".\InventorySharePointSite_" + $now + ".csv"

#SharePoint管理センターのURL
$SharePointAdminCenterUrl = "https://m365x794640-admin.sharepoint.com/"

#-------------------------------------------------
#主処理
#-------------------------------------------------
#SharePoint Onlineに接続する
Connect-SPOService -Url $SharePointAdminCenterUrl -Credential $credential

#テナントを取得する
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SharePointAdminCenterUrl)
$ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($user,$password)
$tenant = New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($ctx) 

#SharePointサイトをすべて取得する
$sites = Get-SPOSite -Limit All

#ゲストユーザーがいるサイトをCSVに出力する
foreach($site in $sites)
{
    #コミュニケーションサイトでなければスキップする
    if($site.Template -ne "SITEPAGEPUBLISHING#0")
    {
        continue
    }

    #外部共有がオフであればスキップする
    if($site.SharingCapability -eq "Disable")
    {
        continue
    }

    #指定したSharePointグループにユーザーがいなければスキップする
    $groups = Get-SPOSiteGroup -Site $site.Url
    $group  = $groups | where { $_.Title -Like "*閲覧者" -or $_.Title -Like "*Visitors" }    

    if([string]::IsNullOrEmpty($group) -eq $true)
    {
        continue
    }
    if($group.Users.Count -ne 0)
    {
        continue
    }

    #サイトIDを取得
    $siteObject = $tenant.GetSiteByUrl($site.Url)
    $ctx.Load($siteObject)  
    $ctx.ExecuteQuery()  
    $siteID = $siteObject.Id | select -ExpandProperty Guid

    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Title  -Value $site.Title
    $obj | Add-Member -MemberType NoteProperty -Name Url    -Value $site.Url
    $obj | Add-Member -MemberType NoteProperty -Name SiteID -Value $siteID

    $obj | Export-Csv -Path $CSVFilePath -Encoding UTF8 -NoTypeInformation -Append -force
}
