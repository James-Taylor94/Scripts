import-Module ActiveDirectory

$Username = Read-Host "Please enter the username"

get-aduser $Username -Properties * | select-object -ExpandProperty accountexpirationdate