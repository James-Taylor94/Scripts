<#
.SYNOPSIS
    This script is designed to create Thrims accounts
.DESCRIPTION
    
.NOTES
    Generated On: 03/05/2021
    Author: James Taylor
#>
Import-Module ActiveDirectory

$RITM= Read-Host "Enter the RITM number of the ticket"

$SamAccountName = Read-Host "Enter the SamAccountName"
$USER = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty UserPrincipalName
    if ($USER) {
        Write-Host "$USER already has taken $SamAccountName" -ForegroundColor Red
     } else {
        Write-Host "$SamAccountName is availble" -ForegroundColor Green
    }

$GivenName = Read-Host "Enter the users first name"
$Surname = Read-Host "Enter the users surname"
$Org = Read-Host "Enter users agency"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@james.local"
$Server = "james.local"
$DisplayName = "$GivenName $Surname"
$Name = $DisplayName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"
$Group = "External Domain Users","APP_THRIMS_USERS"
$Password = ConvertTo-SecureString "1NewFusion" -AsPlainText -Force

$ExternalPath = "OU=ExternalDomainUsers,OU=Accounts,DC=james,DC=local"


New-ADUser -GivenName $GivenName -Surname $Surname `
-SamAccountName $SamAccountName -DisplayName $DisplayName `
-Name $Name -UserPrincipalName $UserPrincipalName -Path $ExternalPath `
-PasswordNeverExpires $false -AccountPassword $Password -Enabled $True `
-ChangePasswordAtLogon $True -Server $Server -Office $Org `
-Company $Org
Add-ADPrincipalGroupMembership $SamAccountName  -MemberOf  $Group
Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External Thrims'}

Get-ADUser $SamAccountName | Set-ADObject -Replace @{primaryGroupID="1124"}
Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName
Set-ADUser -Identity $SamAccountName -Replace @{info="$Notes;"}

Write-Host = Get-ADUser $SamAccountName | Select-Object DisplayName,UserPrincipalName,SamAccountName
