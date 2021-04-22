Import-Module ActiveDirectory
$Users = Get-Content -Path 'File path'

foreach ($User in $Users) {
    Set-ADUser -Identity $User -Office 'Office Name'
}

Write-Host 'Accounts have been updated'