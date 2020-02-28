# initialize vars
. (Join-Path -Path $PSScriptRoot -ChildPath "__init__.ps1")

$cmd = $cmd_fmsadmin + "$args"
Invoke-Expression $cmd -ErrorAction Stop 