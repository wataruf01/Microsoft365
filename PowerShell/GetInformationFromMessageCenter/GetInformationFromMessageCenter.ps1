#-------------------------------------------------
#変数の設定
#-------------------------------------------------
#テナントのID
$tenantID = "XXX-XXX-XXX-XXX-XXX"

#AzureADアプリ
$clientID = "XXX-XXX-XXX-XXX-XXX"

#MSALのリダイレクトURL
$MSALRedirectUri = "msalXXX-XXX-XXX-XXX-XXX://auth"

#-------------------------------------------------
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
$result = Invoke-RestMethod -Method "GET" -Uri $url -Headers $headerParams -ContentType $ContentType
$result.value | Out-GridView
