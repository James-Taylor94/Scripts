Get-ADGroupMember -Identity "smtp change" | Select-Object -ExpandProperty name

Try{
    Remove-ADGroupMember "smtp change" -Members (Get-ADGroupMember "smtp change") -Confirm:$false
     Write-Host "Got rid of the above"
}
Catch{
    "Mate it's already empty"
}