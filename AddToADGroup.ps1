Import-Module ActiveDirectory
$User = Read-Host "Please enter the username"
$Group = Read-Host "Please enter the AD group name"
$ErrorActionPreference = 'Stop'


Add-ADGroupMember -Identity $Group -Members $User

Write-Host "$User has been added to $Group"