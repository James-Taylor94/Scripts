Import-Module ActiveDirectory

$BulkUsers = Get-Content -Path 'C:\temp\Imports\BulkRemove.txt'
$GroupName = Read-Host "Please enter the AD group name"
$ErrorActionPreference = 'Stop'

foreach ($User in $BulkUsers) {
    Remove-ADGroupMember -Identity $GroupName -Members $User -Confirm:$false
}

Write-Host "$BulkUsers have been removed from $GroupName"