<#
.SYNOPSIS
Saves FileMaker Server credentials to a secure file object that can be read securely by other scripts.

.DESCRIPTION
THIS SCRIPT IS INCOMPLETE AND *mostly* UNTESTED (some modifications have come in from people using it successfully)

.PARAMETER filename
filename of the encrypted FMS credentials xml file. This defaults to `WacsFMSCreds.xml`

.PARAMETER path
Folder in which we want to save that credentials file, defaults to 'C:\ProgramData\win-acme'

.PARAMETER u
Username

.PARAMETER p
Password
.EXAMPLE
./SaveFMSCredentials -filename fmsadmincreds.xml -path c:\myfolder -u admin -p somepassword

#>

param(
    [Parameter(Mandatory=$false)]
    [string] $Filename,

    [Parameter(Mandatory=$false)]
    [string] $Path,

    [Parameter(Mandatory=$false)]
    [string] $U,

    [Parameter(Mandatory=$false)]
    [string] $P
)  
$ErrorActionPreference = 'Stop'
$DEFAULT_PATH = "C:\Program Files\FileMaker\FileMaker Server\CStore\"
$DEFAULT_CRED_filename = "WacsFMSCreds.xml"

function Save-Password {

    Write-Host $Filename $Path $U $P

    if (!$Filename) {
        $Filename = Read-Host "Enter filename, (WacsFMSCreds.xml)"
        if ( !$Filename ) { $Filename = $DEFAULT_CRED_filename }
        # Write-Host $Filename
    }
   
    if (!$Path) {
        $Path = Read-Host "Save $Filename to: ($DEFAULT_PATH)"
        if ( !$Path ) { $Path = $DEFAULT_PATH }
    }
 
    #Get credentials securely
    if (!$U -and !$P) { 
        Write-Host 'username and password not specified'
        $Credentials = Get-Credential -message "What is the FileMaker Server admin user and password?"
    } else {

        $PWord = ConvertTo-SecureString -String $P -AsPlainText -Force
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $U, $PWord
    }

    try {
        $Path =  Join-Path -Path $Path -ChildPath $Filename
    }
    catch {
        Write-Host $_.Exception.Message`n
    }
  

    try {
           $Credentials | Export-CliXml $Path
        }
    catch
        {
          Write-Host $_.Exception.Message`n
        }
     
  

    #Test to make sure our creds are good
    
    #$ic = Import-CliXml $Path
    #$PlainTextPassword = $ic.GetNetworkCredential().Password
    #Write-Host "Saved:" $ic.Username $PlainTextPassword

}
 
Save-Password

