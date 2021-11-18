Import-Module ActiveDirectory

$Users = Get-Content -Path "C:\temp\Imports\LocationUpdate.txt"
$Org = Read-Host "What is the organisation"
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Set-ADUser -Identity $User -Company $Org -Office $Org -Server "vwpdcrw0003.dhw.wa.gov.au" -Verbose
}

Write-Host "$users location updated to $org"