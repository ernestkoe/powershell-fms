<#
Loads up the config.json and initializes common vars
#>
$ConfPath = Join-Path -Path $PSScriptRoot -ChildPath "fms_config.json"
$Conf = Get-Content $ConfPath | ConvertFrom-Json
$FMSCredsFileName = $Conf.FMSCredsFilename
$FMSCredsPath = $Conf.FMSCredsPath
$CredsPath = Join-Path -Path $FMSCredsPath -ChildPath $FMSCredsFileName
# Write-Host $CredsPath

# avoid loading up Creds File if there isn't one
if (

    [System.IO.File]::Exists($CredsPath)) {
    $IC = Import-CliXml $CredsPath
    $Username = $IC.Username
    $Password = $IC.GetNetworkCredential().Password
    $cmd_fmsadmin = "fmsadmin -y -u `"$($Username)`" -p `"$($Password)`""
    
    if ($cmd_fmsadmin) {
       # pass
       # does nothing, just a little shim to keep linter happy
    }

}