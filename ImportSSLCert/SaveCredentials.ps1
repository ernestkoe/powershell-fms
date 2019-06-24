$DEFAULT_PATH = "/Library/FileMaker Server/Data/Scripts/"
function Save-Password {
    param(
        [Parameter(Mandatory)]
        [string]$Label
    )
 
    Write-Host 'Input password:'
    $securePassword = Read-host -AsSecureString | ConvertFrom-SecureString
 
    $securePassword | Out-File -FilePath "$DEFAULT_PATH/$Label.txt"
}
 
Save-Password