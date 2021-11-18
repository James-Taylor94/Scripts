Import-Module ActiveDirectory

$User = Get-Content -Path "C:\temp\Imports\Users.txt"

foreach($User in $User){
    get-aduser -Identity $User -Properties * | Select-Object -ExpandProperty CanonicalName
}
Write-Host "Hi Chantelle"