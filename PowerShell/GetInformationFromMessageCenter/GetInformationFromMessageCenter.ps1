#-------------------------------------------------
#変数の設定
#-------------------------------------------------
#テナントのID
$tenantID = "XXX-XXX-XXX-XXX-XXX"

#AzureADアプリ
$clientID = "XXX-XXX-XXX-XXX-XXX"

#MSALのリダイレクトURL
$MSALRedirectUri = "msalXXX-XXX-XXX-XXX-XXX://auth"

-------------------------------------------------
#認証情報を取得
#------------------------------------------------- 
#トークンを取得
$token = Get-MsalToken `
-TenantId    $tenantID `
-ClientId    $clientID `
-RedirectUri $MSALRedirectUri `
-Interactive 

$headerParams = @{
    'Authorization' = "bearer $($token.AccessToken)"
}

#-------------------------------------------------
#メッセージセンターの情報を取得
#------------------------------------------------- 
$url = "https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/messages"
$contentType = "application/json"

$responseFromAPI = Invoke-RestMethod `
-Method  GET `
-uri     $pages `
-Headers $headerParams `
-ContentType $contentType

$result = @()
$result += $responseFromAPI.value

$pages = $responseFromAPI.'@odata.nextLink'

while([string]::IsNullOrEmpty($pages) -eq $false)
{
    $addtional = Invoke-RestMethod `
    -Method  GET `
    -uri     $pages `
    -Headers $headerParams `
    -ContentType $contentType
                  
    $result += $addtional.value

    $pages = $addtional."@odata.nextLink"
}

$result | Out-GridView
