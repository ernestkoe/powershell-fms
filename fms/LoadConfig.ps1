$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$Conf = Get-Content $scriptDir\config.JSON | ConvertFrom-Json
$FMSCredsFileName = $Conf.FMSCredsFilename
$FMSCredsPath = $Conf.FMSCredsPath

$CredsPath = Join-Path -Path $FMSCredsPath -ChildPath $FMSCredsFileName
$IC = Import-CliXml $CredsPath
$Username = $IC.Username
$Password = $IC.GetNetworkCredential().Password
$cmd_fmsadmin = "fmsadmin -y -u `"$($Username)`" -p `"$($Password)`""