import-Module ActiveDirectory

$GroupName = Read-Host "Enter the AD Group name"
$ExportPath = "C:\Temp\Exports\$GroupName-GroupMembership.csv"

Get-ADGroupMember -Identity $GroupName | select name,samaccountname | Export-Csv -Path $ExportPath -NoTypeInformation
Write-Host "Exported members of $GroupName"