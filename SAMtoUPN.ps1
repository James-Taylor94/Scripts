<#
.SYNOPSIS
    This script is designed to query a list of UPN's and export their Samaccountname attribute
.DESCRIPTION
    First create a CSV file containing a list of UPNs you want to query and update the $User variable input
.NOTES
    Generated On: 19/04/2021
    Author: Matthew Heuer
#>

$Users = Get-Content 'C:\temp\Imports\UPNtoSAM.txt'

$Users | ForEach-Object {(Get-ADUser -Filter "SAMAccountName -eq '$_'" -Properties *).UserPrincipalName} | Out-File "C:\temp\Exports\BulkAdd.txt"