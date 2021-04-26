Import-Module ActiveDirectory
$Users = Get-Content -Path "C:\temp\sAMAccountname.txt"
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Set-ADUser -Identity $user -Office 'Wanslea -Verbose'
}

Write-Host "Accounts successfully udpated"