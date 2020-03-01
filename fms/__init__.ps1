<#
Loads up the config.json and initializes common vars
#>

$configFileName = "fms_config.json"
$ConfPath = Join-Path -Path $PSScriptRoot -ChildPath $configFileName
#Write-Host $ConfPath
$TemplatePath = Join-Path -Path $PSScriptRoot -ChildPath "$configFileName-template"

<# make a config file from the template#>
if ( ! (Test-Path $ConfPath))
        { Copy-Item -path $TemplatePath -destination $ConfPath}

$Conf = Get-Content $ConfPath | ConvertFrom-Json
$FMSCredsFileName = $Conf.FMSCredsFilename
$FMSCredsPath = $Conf.FMSCredsPath
$CredsPath = Join-Path -Path $FMSCredsPath -ChildPath $FMSCredsFileName
# Write-Host $CredsPath

# avoid loading up Creds File if there isn't one
if ( Test-Path $CredsPath )
{
    $IC = Import-CliXml $CredsPath
    $Username = $IC.Username
    $Password = $IC.GetNetworkCredential().Password
    $cmd_fmsadmin = "fmsadmin -y -u `"$($Username)`" -p `"$($Password)`""
    
    if ($cmd_fmsadmin) {
       # pass
       # does nothing, just a little shim to keep linter happy
    }
}