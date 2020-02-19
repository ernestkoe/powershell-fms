<#
.SYNOPSIS
Imports a cert from WASC renewal into FileMaker server.

.DESCRIPTION
Note that this script is intended to be run via the install script plugin from WASC via the batch script wrapper. As such, we use positional parameters to avoid issues with using a dash in the cmd line.

THIS SCRIPT IS INCOMPLETE AND *mostly* UNTESTED (some modifications have come in from people using it successfully)
Documentation referenced from https://technet.microsoft.com/en-us/library/aa997231(v=exchg.160).aspx

Proper information should be available here
https://github.com/PKISharp/win-acme/wiki/Install-Script
or more generally, here 
https://github.com/PKISharp/win-acme/wiki/Example-Scripts

.PARAMETER Hostname
Hostname to use when importing the .pem files.

.PARAMETER CertPath
Path to the WACS certificate directory. The certificate that is imported will be "{$hostanme}-chain.pem" from this directory. 

.PARAMETER WACSFMSCredsPath
Path to the WACSFMSCreds.xml file. This file contains the encrypted filemaker server admin credentials 

.PARAMETER DebugOn
Include this switch parameter to write debug outputs for troubleshooting

.PARAMETER Usage
`InstallSSL.ps1 --host text.example.com -C C:\programdata\win-acme`
#>

param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]
    $Hostname,
    
    [Parameter(Position = 1, Mandatory = $false)]
    [string]
    $CertPath,

    [Parameter(Position = 2, Mandatory = $false)]
    [string]
    $WACSFMSCredsFileName,

    [Parameter(Position = 3, Mandatory = $false)]
    [string]
    $WACSFMSCredsPath,

    [switch]$DebugOn
)

if ($DebugOn) {
    $DebugPreference = "Continue"
}
<#
TODO: check to make sure config.json vars are good
#>

$ErrorActionPreference = 'Stop'
$env = Get-Content config.JSON | ConvertFrom-Json

Write-Host $Hostname $CertPath $WACSFMSCredsFileName $WACSFMSCredsPath

if ( !$Hostname ) {
    $Hostname = Read-Host "Hostname"
    if ( [string]::isNullOrEmpty($Hostname)) {
        Write-Output "Script halted with error: A hostname like, foo.example.com is required"
        exit
    } 
}


if ( !$CertPath ) {
    $CertPath = Read-Host "Location of SSL certificates ($($env.DEFAULT_FMS_CSTORE_PATH))"
    if ( [string]::isNullOrEmpty($CertPath)) { 
        $CertPath = $env.DEFAULT_FMS_CSTORE_PATH
    }
}

if ( !$WACSFMSCredsFileName ) {
    $WACSFMSCredsFileName = Read-Host "Encrtypted FMS Credentials file name ($($env.DEFAULT_WacsFMSCredsFilename))"
    if ( !$WACSFMSCredsFileName ) { 
        $WACSFMSCredsFileName = $env.DEFAULT_WacsFMSCredsFilename 
    }
}

if ( !$WACSFMSCredsPath ) {
    $WACSFMSCredsPath = Read-Host "Location of FMS Credentials encrypted file ($($env.DEFAULT_FMS_CSTORE_PATH))"
    if ( !$WACSFMSCredsPath ) { $WACSFMSCredsPath = $env.DEFAULT_FMS_CSTORE_PATH }
    else {
        $WACSFMSCredsPath
    }
}

$CERT_FILENAME = "$($Hostname)-chain.pem"
$KEY_FILENAME = "$($Hostname)-key.pem"

try { $ImportCertFilePath = Join-Path -Path $CertPath -ChildPath $CERT_FILENAME }
catch {	Write-Output "Script halted with error related to the certificate path" }

try { $ImportKeyFilePath = Join-Path -Path $CertPath -ChildPath $KEY_FILENAME }
catch { Write-Output "Script halted with error related to the key path" }

try { $CredsPath = Join-Path -Path $WACSFMSCredsPath -ChildPath $WACSFMSCredsFileName }
catch { Write-Output "Script halted with error related to the encprypted fms creds path" }

#load input credentials
$IC = Import-CliXml $CredsPath
$Username = $IC.Username
$Password = $IC.GetNetworkCredential().Password
Write-Host "Plaintext Password:" $PlainTextPassword

# Print debugging info to make sure the parameters arrived
if ($DebugOn) {
    Write-Host "FileMaker Server Host Name: $Hostname"
    Write-Host "Certificate Path: $ImportCertFilePath"
    Write-Host "Keyfile Path: "$ImportKeyFilePath
    Write-Host "username: "$Username
    Write-Host "password: "$Password
}

$ImportCertCmd = "fmsadmin -y -u `"$Username`" -p `"$Password`" CERTIFICATE IMPORT `"$ImportCertFilePath`" --keyfile `"$ImportKeyFilePath`""
$RestartServerCmd = "fmsadmin -y -u `"$Username`" -p `"$Password`" restart server"

if ($DebugOn) {
    Write-Host $ImportCertCmd
    Write-Host $RestartServerCmd
}
else {
    Invoke-Expression $ImportCertCmd
    Invoke-Expression $RestartServerCmd
}

