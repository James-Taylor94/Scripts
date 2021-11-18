<#
.SYNOPSIS
   | To add user to multiple Dl's in Exchange \\dhw.wa.gov.au\corporatedata\IS\TSS\Support Centre\Helpdesk Services\Scripts

   .Description
   Test script for bulk Dl add
<#>
Import-Module ActiveDirectory

$UserEmail = Read-Host -Prompt "Enter The User Email Address"

$DlAddress = Read-Host -Prompt "Enter the Distribution address you want to add the user to $DlAddress"
#$DlAddress = $DLAddress.Split(',') 


foreach ($DLAddress in $DLAddresses){
  Add-DistributionGroupMember -Identity $DLAddress –Member $UserEmail
}
##Add-DistributionGroupMember -Identity $DLAddress –Member $UserEmail