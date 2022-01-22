#Features:
#Backup of Power BI Report as PBIX file
#Backup of all Power BI Reports in Workspace
#Backup of all Power BI Report in multiple Workspaces
param(
    [string]$Environment,
    [string]$ProjectFolder
    )

# Power BI REST API URIS
$PowerBI_REST_API_TOKEN="https://login.windows.net/common/oauth2/token"

$CONFIG=Get-Content -Path "$($ProjectFolder)\PowerBI-Exporter.$($Environment).config.json" | ConvertFrom-Json

$Payload = @{
    'grant_type'   = 'password'
    'scope'        = 'openid'
    'resource'     = 'https://analysis.windows.net/powerbi/api'
    'client_id'    = $CONFIG.POWERBI_APP_CLIENT_ID
    'client_secret'= $CONFIG.POWERBI_APP_CLIENT_SECRET
    'username'     = $CONFIG.POWERBI_APP_USER_NAME
    'password'     = $CONFIG.POWERBI_APP_PASSWORD
}

Write-HostLog -Message "Getting access token from Power BI Service..."
$PowerBI_TOKEN_RESPONSE = Invoke-RestMethod -Method Post -Uri $PowerBI_REST_API_TOKEN -Body $Payload
$PowerBI_TOKEN_JSON = $PowerBI_TOKEN_RESPONSE.token_type + ' ' + $PowerBI_TOKEN_RESPONSE.access_token
Write-HostLog -Message "Access token:$PowerBI_TOKEN_JSON"