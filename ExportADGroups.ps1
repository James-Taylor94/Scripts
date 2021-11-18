import-Module ActiveDirectory

$SAM = Read-Host "Enter the sAMAccountname of the terminated user"
$USER = Get-ADUser -Identity $SAM
    if ($USER) {
          Write-Host "Found user $USER with username: $SAM" -ErrorAction Stop
     } else {
          Write-Warning "No user in AD found using the username: $SAM"
          Exit
     }

$RITM= Read-Host "Enter the RITM number of the ticket"
$ContextServer = Get-ADDomain | Select-Object -ExpandProperty forest

if ($ContextServer -eq 'dhw.wa.gov.au') {
    $MemberPath = "\\dhw.wa.gov.au\corporatedata\IS\TSS\Support Centre\EntOps\Scripts\Exports\$RITM-$SAM-GroupMembership-$Date.csv"
} else {
    $MemberPath = "C:\temp\Exports\$RITM-$SAM-GroupMembership-$Date.csv"
}

Get-ADPrincipalGroupMembership $USER -ResourceContextServer $ContextServer | Export-Csv -Path $MemberPath -NoTypeInformation
