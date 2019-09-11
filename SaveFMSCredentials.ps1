$DEFAULT_PATH = "C:\Program Files\FileMaker\FileMaker Server\CStore"
$DEFAULT_CRED_FILENAME = "WacsFMSCreds.xml"

function Save-Password {

    param(
        [Parameter(Mandatory=$false)]
        [string]
        $Filename,

        [Parameter(Mandatory=$false)]
        [SecureString]
        $CredsPath
    )

    if (!$Filename) {
        $Filename = Read-Host "Enter filename, (WacsFMSCreds.xml)"
        if ( !$Filename ) { $Filename = $DEFAULT_CRED_FILENAME }
        # Write-Host $Filename
    }
   
    if (!$CredsPath) {
        $CredsPath = Read-Host "Save $Filename to: ($DEFAULT_PATH)"
        if ( !$CredsPath ) { $CredsPath = $DEFAULT_PATH }
    }
 
    #Get credentials securely
    $Credentials = Get-Credential -message "What is the FileMaker Server admin user and password?"

    $Path =  Join-Path -Path $CredsPath -ChildPath $Filename
    $Credentials | Export-CliXml $Path

    #Test to make sure our creds are good
     # $ic = Import-CliXml $Path
     # $Password = $ic.Password | ConvertFrom-SecureString
     # $PlainTextPassword = $ic.GetNetworkCredential().Password
     # Write-Host "Saved:" $ic.Username $PlainTextPassword

     Write-Host "Saved to $Path"
}
 
Save-Password
