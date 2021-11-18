
Import-Module ActiveDirectory

$User = Read-Host "Enter the sAMAccountName of the user"
(Get-ADuser -Identity $User -Properties memberof).memberof
$Groups = Get-Content -Path "C:\temp\Imports\GroupImport.txt"


foreach($Group in $Groups){
    Add-ADPrincipalGroupMembership $User -MemberOf $Group
}