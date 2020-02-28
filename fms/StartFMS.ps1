# initialize vars
. (Join-Path -Path $PSScriptRoot -ChildPath "__init__.ps1")

$processTypes =  $Conf.StartupSequence

$cmd_fmsadmin = "fmsadmin -y -u `"$($Username)`" -p `"$($Password)`""

Foreach ($pt in $processTypes ) {
    $cmd_start = $cmd_fmsadmin +  " START $($pt)" 
    write-host "Starting up $pt..."
    Invoke-Expression $cmd_start -ErrorAction Stop
} 

   # Invoke-Expression $RestartServerCmd -ErrorAction Stop
