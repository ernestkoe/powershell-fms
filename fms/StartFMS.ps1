$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $scriptDir\LoadConfig.ps1

$processTypes =  $Conf.StartupSequence

#$cmd_fmsadmin = "fmsadmin -y -u `"$($Username)`" -p `"$($Password)`""

Foreach ($pt in $processTypes ) {
    $cmd_start = $cmd_fmsadmin +  " START $($pt)" 
    write-host $cmd_start
    Invoke-Expression $cmd_start -ErrorAction Stop
}

   # Invoke-Expression $RestartServerCmd -ErrorAction Stop
