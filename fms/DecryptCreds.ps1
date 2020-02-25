#load input credentials
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $scriptDir\LoadConfig.ps1

Write-Host "Username: $($Username)
Password: $($Password)"