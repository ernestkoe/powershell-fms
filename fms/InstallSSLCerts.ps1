<#
.SYNOPSIS
Imports a cert from WASC/Letsencrypt renewal into FileMaker server.

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

.PARAMETER FMSCredsFileName
This file contains the encrypted filemaker server admin credentials 

.PARAMETER FMSCredsPath
Path to the file containing the encrypted filemaker server admin credentials

.PARAMETER DebugOn
Include this switch parameter to write debug outputs for troubleshooting

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
    $FMSCredsFileName,

    [Parameter(Position = 3, Mandatory = $false)]
    [string]
    $FMSCredsPath,

    [switch]$DebugOn
)

if ($DebugOn) {
    $DebugPreference = "Continue"
}
<#
TODO: check to make sure config.json vars are good
#>

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $scriptDir\LoadConfig.ps1

$configpath = Join-Path -Path $PSScriptRoot -ChildPath "config.json" 
write-host $configpath
$Conf = Get-Content $configpath | ConvertFrom-Json

if ( !$Hostname ) {
    $Hostname = $Conf.Hostname

    if ( !$Hostname ) {
        $Hostname = Read-Host "Hostname"
        if ( [string]::isNullOrEmpty($Hostname)) {
            Write-Output "Script halted with error: A hostname like, foo.example.com is required"
            exit
        } 
    }
}

if ( !$CertPath ) {
    $CertPath = $Conf.FMSCStorePath
    if ( !$CertPath ) {
        $CertPath = Read-Host "Location of SSL certificates"
        if ( [string]::isNullOrEmpty($CertPath)) { 
            Write-Output "Script halted with error: Certificate path is required"
            exit
        }
    }
}

if ( !$FMSCredsFileName ) {
    $FMSCredsFileName = $Conf.FMSCredsFilename
    if ( !$FMSCredsFileName ) {
        $FMSCredsFileName = Read-Host "Encrtypted FMS Credentials file name"
        if ( !$FMSCredsFileName ) { 
            Write-Output "Script halted with error: FMSCredsFilename is required"
            exit
        }
    }
}

if ( !$FMSCredsPath ) {
    $FMSCredsPath = $Conf.FMSCredsPath
    if ( !$FMSCredsPath ) {
        $FMSCredsPath = Read-Host "Location of FMS Credentials encrypted file"
        if ( !$FMSCredsPath ) {
            Write-Output "Script halted with error: FMSCredsPath is required"
            exit
        }
    }
}

$CERT_FILENAME = "$($Hostname)-chain.pem"
$KEY_FILENAME = "$($Hostname)-key.pem"

try { $ImportCertFilePath = Join-Path -Path $CertPath -ChildPath $CERT_FILENAME }
catch {	Write-Output "Script halted with error related to the certificate path" }

try { $ImportKeyFilePath = Join-Path -Path $CertPath -ChildPath $KEY_FILENAME }
catch { Write-Output "Script halted with error related to the key path" }

try { $FMSCredsPath = Join-Path -Path $FMSCredsPath -ChildPath $FMSCredsFileName }
catch { Write-Output "Script halted with error related to the encprypted fms creds path" }



# Print debugging info to make sure the parameters arrived
if ($DebugOn) {
    Write-Host "FileMaker Server Host Name: $Hostname"
    Write-Host "Certificate Path: $ImportCertFilePath"
    Write-Host "Keyfile Path: "$ImportKeyFilePath
    Write-Host "Username: "$Username
    Write-Host "Password: "$Password
}

$ImportCertCmd = "fmsadmin -y -u `"$Username`" -p `"$Password`" CERTIFICATE IMPORT `"$ImportCertFilePath`" --keyfile `"$ImportKeyFilePath`""
$RestartServerCmd = "fmsadmin -y -u `"$Username`" -p `"$Password`" restart server"
Write-Host $ImportCertCmd
if ($DebugOn) {
    Write-Host $ImportCertCmd
    Write-Host $RestartServerCmd
}
else {
    if ([System.IO.File]::Exists($ImportCertFilePath)) {
        Invoke-Expression $ImportCertCmd -ErrorAction Stop

    }
    else {
        Write-Output "$($ImportCertFilePath) cannot be found"
        exit
    }
    
    Invoke-Expression $RestartServerCmd -ErrorAction Stop
}