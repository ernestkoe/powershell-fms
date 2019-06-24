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


.PARAMETER FriendlyName
Friendly name to use when importing the .pem files.

.PARAMETER CertificatePath
Path to the WACS certificate directory. The certificate that is imported will be "$(FriendlyName)-cert.pem" from this directory. 

.PARAMETER DebugOn
Include this switch parameter to write debug outputs for troubleshooting

#>

param(
	[Parameter(Position=0,Mandatory=$true)]
	[string]
	$ServerHostName,
    
    [Parameter(Position=1,Mandatory=$true)]
	[string]
	$CertificatePath,	
	[switch]$DebugOn
)

if($DebugOn){
	$DebugPreference = "Continue"
}

#FileMaker server permissions, this should be stored in an encrypted file, this is no beauno

$fms = @{ 
    username =  $username  #FileMaker Server admin account username, e.g. 'Admin'
    password =  $password  #FileMaker Server admin password
	certificate = "$CertificatePath\$ServerHostName-chain.pem"
	keyfile = "$CertificatePath\$ServerHostName-key.pem"
    # chain_path =  "$CertificatePath\$ServerHostName-chain.pem"


}

# Print debugging info to make sure the parameters arrived

Write-Host "ServerHostName: $ServerHostName"
Write-Host "CertificatePath: $CertificatePath"
Write-Host "crt_path: "$fms.certificate
Write-Host "chain_path: "$fms.keyfile
Write-Host "username: "$fms.username
Write-Host "password: "$fms.password

$cmd1 = "fmsadmin -y -u $fms.username -p $fms.password CERTIFICATE IMPORT $fms.certificate --keyfile $fms.keyfile"
$cmd2 = "fmsadmin -y -u $fms.username -p $fms.password restart server"

if ($DebugOn)
    {
    Write-Host $cmd1
    Write-Host $cmd2
	}
else {
	Invoke-Expression $cmd1
	Invoke-Expression $cmd2
	}

