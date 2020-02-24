# based on article found here:
# https://www.burnham.io/2017/02/dynamic-dns-using-amazon-route-53-and-powershell/
# but it's pretty terrible, so i rewrote it.

#import AWSPowerShell.NetCore

Import-Module AWSPowerShell.NetCore

$Config = "./r53_config.json"
$ConfigJSON = Get-Content -Raw -Path $Config | ConvertFrom-Json


$ResourceRecords = @{Value='127.0.0.1'}
$Name = "TheName"

$TheObject = @( 
    @{ 
        Comment = 'Update the A record set'
        Changes = @( 
            @{ 
                Action='UPSERT'
                ResourceRecordSet=
                @{
                    Name = $Name
                    Type = 'A'

                }
        }
        )
    }
)