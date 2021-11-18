Import-Module ActiveDirectory

$DistributionList = Read-Host "Please enter the Distribution List email"

Get-DistributionGroupMember $DistributionList | select name | export-csv -Path C:\temp\Exports\GroupMembers.csv -NoTypeInformation