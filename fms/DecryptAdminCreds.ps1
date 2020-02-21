#load input credentials

$env = Get-Content config.JSON | ConvertFrom-Json
$FMSCredsFileName = $env.FMSCredsFilename
$FMSCredsPath = $env.FMSCredsPath

$CredsPath = Join-Path -Path $FMSCredsPath -ChildPath $FMSCredsFileName
$IC = Import-CliXml $CredsPath
$Username = $IC.Username
$Password = $IC.GetNetworkCredential().Password
Write-Host "Username: $($Username)
Password: $($Password)"
