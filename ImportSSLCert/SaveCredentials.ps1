$DEFAULT_PATH = "/Program Files/FileMaker/FileMaker Server/CStore"

function Save-Password {

    param(
        [Parameter(Mandatory=$false)]
        [string]
        $filename
    )

    if (!$filename) {
        $filename = Read-Host "Enter filename, (defaults to 'fms_creds.xml')"
        if ( !$filename ) { $filename = "fms_creds.xml" }
        Write-Host $filename
    }

    $credentials = Get-Credential -message "What is the FileMaker Server admin user and password?"

    $path =  Join-Path -Path $DEFAULT_PATH -ChildPath $filename
    $credentials | Export-CliXml $path

    #Test to make sure our creds are good
     $ic = Import-CliXml $path
     # $Password = $ic.Password | ConvertFrom-SecureString
     $PlainTextPassword = $ic.GetNetworkCredential().Password
     Write-Host "Test:" $ic.Username $PlainTextPassword
}
 
Save-Password