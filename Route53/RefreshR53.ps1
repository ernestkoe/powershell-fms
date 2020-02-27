# adapated from: 
# https://www.burnham.io/2017/02/dynamic-dns-using-amazon-route-53-and-powershell/
# 

Import-Module AWSPowerShell

# Import from JSON object
$Path = "r53_config.json"
$JSONdata = Get-Content -Raw -Path $Path | ConvertFrom-Json

$DomainName = $JSONdata.Name
$cZone = $JSONData.Zone
write-host $DomainName

# Create the FQDN
If($JSONdata.Subdomain)
{
    $FQDN = @($JSONdata.Subdomain, $DomainName) -join '.'
}
Else
{
    $FQDN = @($DomainName, $cZone) -join '.'
    write-host $FQDN
}

# Get the Hosted Zone
write-host "DomainName: $DomainName, $cZone"
$Zone = Get-R53HostedZones | Where-Object {$_.Name -eq $cZone}

Write-host "Testing for $Zone"

If($Zone)
{
    # Get the resource record sets for this zone, taking care to pull as many records as there are in the zone.
    $ResourceRecords = Get-R53ResourceRecordSet -HostedZoneId $Zone.Id -MaxItem $Zone.ResourceRecordSetCount | % {$_.ResourceRecordSets}

    Write-Host $ResourceRecords

    $Record = $ResourceRecords | Where-Object {$_.Name -eq $FQDN -AND $_.Type -eq "CNAME"} | % {$_.ResourceRecords}
    Write-Host $Record
    # Get your public IP
    $PublicIP = (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json').ip
    Write-Host ("Checking public IP against resource record.")
    If($Record.Value -ne $PublicIP)
    {
        Write-Host ("Public IP {0} != {1}" -f $PublicIP, $Record.Value)
        # Create the new ResourceRecordSet
        $UpdatedResourceRecord = New-Object Amazon.Route53.Model.ResourceRecordSet
        $UpdatedResourceRecord.Name = $FQDN
        $UpdatedResourceRecord.Type = "CNAME"
        # Set the resource record using the public IP Get-R53ResourceRecordSet -HostedZoneId $Zone.Id -MaxItem $Zone.ResourceRecordSetCount | % {$_.ResourceRecordSets}
        $UpdatedResourceRecord.ResourceRecords = (New-Object Amazon.Route53.Model.ResourceRecord($PublicIP))
        $UpdatedResourceRecord.TTL = ($Record.TTL)
        # Create the R53 change action
        $Change = New-Object Amazon.Route53.Model.Change
        $Change.Action = [Amazon.Route53.ChangeAction]::UPSERT
        $Change.ResourceRecordSet = $UpdatedResourceRecord
        # Push the change up
        $ChangeBatch = Edit-R53ResourceRecordSet -HostedZoneId $Zone.Id -ChangeBatch_Change $Change
        Write-Host ("Change filed at {0} with ID {1} against {2}" -f $ChangeBatch.SubmittedAt, $ChangeBatch.Id, $FQDN)
    }
    Else
    {
        Write-Host ("IPs match. No changes")
    }
}
Else
{
    throw("Unable to locate hosted zone for domain {0}" -f $DomainName)
}