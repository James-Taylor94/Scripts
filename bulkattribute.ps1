Import-Module ActiveDirectory
$Users = Get-Content -Path "C:\temp\Imports\BulkEndDate.txt"
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Set-ADAccountExpiration -Identity $User -DateTime "08/09/2022" -Verbose
}

Write-Host "End date successfully updated"