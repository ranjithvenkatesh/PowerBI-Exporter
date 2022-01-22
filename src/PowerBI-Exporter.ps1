#Features:
#Backup of Power BI Report as PBIX file
#Backup of all Power BI Reports in Workspace
#Backup of all Power BI Report in multiple Workspaces
param(
    [string]$ProjectFolder,
    [string]$Environment,
    [string]$ReportID,
    [string]$ReportName,
    [string]$WorkspaceID
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
 
Write-HostLog -Message "Exporting Report..."
$PowerBI_REPORT_EXPORT_API = "https://api.powerbi.com/v1.0/myorg/reports/" + $ReportID + "/Export"
$PowerBI_REPORT_Name = $ReportName + ".pbix"
Invoke-RestMethod -Method Get -Uri $PowerBI_REPORT_EXPORT_API -ContentType 'application/zip' -Headers @{authorization = $PowerBI_TOKEN_JSON} -OutFile $PowerBI_REPORT_Name
Write-HostLog -Message "Report exported."

$PowerBI_REST_API_Groups = "https://api.powerbi.com/v1.0/myorg/groups"
$PowerBI_REST_API_GroupReports = $PowerBI_REST_API_Groups + "/" + $WorkspaceID + "/" + "reports"
Write-HostLog -Message "Getting Reports in Workspace..."
$PowerBI_SSBI_Reports = Invoke-RestMethod -Method Get -Uri $PowerBI_REST_API_GroupReports -ContentType 'application/json' -Headers @{authorization = $PowerBI_TOKEN_JSON}
Write-HostLog -Message "Number of Reports in Workspace:"
Write-Host $PowerBI_SSBI_Reports.value.Count
$PowerBI_SSBI_Reports.value | Format-Table