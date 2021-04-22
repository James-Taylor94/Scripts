Import-Module ActiveDirectory
$Users = Get-Content -Path 'C:\temp\'
$ErrorActionPreference = 'Stop'

foreach ($User in $Users) {
    Add-ADGroupMember - Identity External_User -Members $Users
}

Write-host 'Accounts have been added to the group'