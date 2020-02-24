$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $scriptDir\LoadConfig.ps1

$cmd = $cmd_fmsadmin + "$args"
Invoke-Expression $cmd -ErrorAction Stop 