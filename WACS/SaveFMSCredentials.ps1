<#
.SYNOPSIS
Saves FileMaker Server credentials to a secure file object that can be read securely by other scripts.

.DESCRIPTION
THIS SCRIPT IS INCOMPLETE AND *mostly* UNTESTED (some modifications have come in from people using it successfully)

.PARAMETER filename
filename of the encrypted FMS credentials xml file. This defaults to `WacsFMSCreds.xml`

.PARAMETER path
Folder in which we want to save that credentials file, defaults to 'C:\ProgramData\win-acme'

#>

param(
    [Parameter(Mandatory=$false)]
    [string] $filename,

    [Parameter(Mandatory=$false)]
    [string] $path,

    [Parameter(Mandatory=$false)]
    [string] $u,

    [Parameter(Mandatory=$false)]
    [string] $p

)  
$DEFAULT_PATH = "C:\ProgramData\win-acme"
$DEFAULT_CRED_filename = "WacsFMSCreds.xml"

function Save-Password {

    Write-Host $filename $path $u $p
    if (!$filename) {
        $filename = Read-Host "Enter filename, (WacsFMSCreds.xml)"
        if ( !$filename ) { $filename = $DEFAULT_CRED_filename }
        # Write-Host $filename
    }
   
    if (!$path) {
        $path = Read-Host "Save $filename to: ($DEFAULT_PATH)"
        if ( !$path ) { $path = $DEFAULT_PATH }
    }
 
    #Get credentials securely
    if (!$u -and !$p) { 
        Write-Host 'username and password not specified'
        $Credentials = Get-Credential -message "What is the FileMaker Server admin user and password?"
    } else {

        $PWord = ConvertTo-SecureString -String $p -AsPlainText -Force
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $u, $PWord
    }


    $Path =  Join-Path -Path $path -ChildPath $filename
    $Credentials | Export-CliXml $Path
     
    Write-Host "Encrypted FileMaker Server Credentials saved to $Path"

    #Test to make sure our creds are good
    
    #$ic = Import-CliXml $Path
    #$PlainTextPassword = $ic.GetNetworkCredential().Password
    #Write-Host "Saved:" $ic.Username $PlainTextPassword

}
 
Save-Password

