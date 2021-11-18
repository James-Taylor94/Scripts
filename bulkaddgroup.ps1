Import-Module ActiveDirectory
$Users = Get-Content -Path 'C:\temp\Imports\BulkAdd.txt'
$Group = Read-Host "Please enter the AD group name"
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Add-ADGroupMember -Identity $Group -Members $User -Verbose
}

Write-Host "$Users have been added to $Group"