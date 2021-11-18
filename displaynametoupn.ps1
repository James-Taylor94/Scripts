import-module ActiveDirectory

$Users = Get-Content 'C:\temp\Imports\SAM.txt'
foreach ($User in $Users) {
    (Get-ADUser -Filter "DisplayName -eq '$User'" -Properties *).UserPrincipalName
}