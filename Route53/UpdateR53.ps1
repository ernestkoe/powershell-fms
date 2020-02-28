# adapated from: 
# https://www.burnham.io/2017/02/dynamic-dns-using-amazon-route-53-and-powershell/
# @ernestkoe, The Proof Group LLC

Import-Module AWSPowerShell

# Import from JSON object


$ConfPath = Join-Path -Path $PSScriptRoot -ChildPath "r53_config.json"
$JSONData = Get-Content $ConfPath | ConvertFrom-Json

$DomainName = $JSONdata.Name
$Zone = $JSONData.Zone
$RecordType = $JSONData.RecordType
$TTL = $JSONData.TTL
# write-host $DomainName

# Create the FQDN
If ($JSONdata.Subdomain) {
    $FQDN = @($JSONdata.Subdomain, $DomainName) -join '.'
}
Else {
    $FQDN = @($DomainName, $Zone) -join '.'
    # write-host $FQDN
}

# Get the Hosted AWSZones

# write-host "DomainName: $DomainName, $Zone"
$AWSZones = Get-R53HostedZones | Where-Object { $_.Name -eq $Zone }

If ($AWSZones) {
    # Get the resource record sets for this AWSZones, taking care to pull as many records as there are in the AWSZones.
    $ResourceRecords = Get-R53ResourceRecordSet -HostedZoneId $AWSZones.Id -MaxItem $AWSZones.ResourceRecordSetCount | % { $_.ResourceRecordSets }

    # Write-Host $ResourceRecords

    $Record = $ResourceRecords | Where-Object { $_.Name -eq $FQDN -AND $_.Type -eq $RecordType } | % { $_.ResourceRecords }
    # Write-Host $Record

    # Get your public IP
    $PublicIP = (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json').ip
    Write-Host ("Checking public IP against resource record.")
    If ($Record.Value -ne $PublicIP) {
        Write-Host ("Public IP {0} != {1}" -f $PublicIP, $Record.Value)
        # Create the new ResourceRecordSet
        $UpdatedResourceRecord = New-Object Amazon.Route53.Model.ResourceRecordSet
        $UpdatedResourceRecord.Name = $FQDN
        $UpdatedResourceRecord.Type = $RecordType
        # Set the resource record using the public IP Get-R53ResourceRecordSet -HostedZoneId $AWSZones.Id -MaxItem $AWSZones.ResourceRecordSetCount | % {$_.ResourceRecordSets}
        $UpdatedResourceRecord.ResourceRecords = (New-Object Amazon.Route53.Model.ResourceRecord($PublicIP))
        #$UpdatedResourceRecord.TTL = ($Record.TTL)
        $UpdatedResourceRecord.TTL = ($TTL)
        # Create the R53 change action
        $Change = New-Object Amazon.Route53.Model.Change
        $Change.Action = [Amazon.Route53.ChangeAction]::UPSERT
        $Change.ResourceRecordSet = $UpdatedResourceRecord
        # Push the change up
        $ChangeBatch = Edit-R53ResourceRecordSet -HostedZoneId $AWSZones.Id -ChangeBatch_Change $Change
        Write-Host ("Change filed at {0} with ID {1} against {2}" -f $ChangeBatch.SubmittedAt, $ChangeBatch.Id, $FQDN)
    }
    Else {
        Write-Host ("IPs match. No changes")
    }
}
Else {
    throw("Unable to locate hosted AWSZones for domain {0}" -f $DomainName)
}