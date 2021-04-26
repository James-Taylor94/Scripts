Import-Module ActiveDirectory
$Users = Get-Content -Path 'C:\temp\sAMAccountname.txt'
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Add-ADGroupMember -Identity External_Users -Members $User -Verbose
}

Write-Host "$Users have been added to External_Users"