param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]
    $msg
)

# initialize vars
. (Join-Path -Path $PSScriptRoot -ChildPath "__init__.ps1")

$processTypes = $Conf.ShutdownSequence
$msg = if ($msg) { $msg_txt = "`"$($smg)`"" }
$cmd_disco = $cmd_fmsadmin + " DISCONNECT CLIENT -m $($msg_txt)"

write-host $cmd_disco
Invoke-Expression $cmd_disco

Foreach ($pt in $processTypes ) {
    $cmd_stop = $cmd_fmsadmin +  " STOP $($pt)" 
    write-host "Stopping $pt..."
    Invoke-Expression $cmd_stop -ErrorAction Stop
}

   # Invoke-Expression $RestartServerCmd -ErrorAction Stop
