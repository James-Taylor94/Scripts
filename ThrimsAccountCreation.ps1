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
     } elseif (!$USER) {
        Write-Host "$SamAccountName is availble" -ForegroundColor Green
    }

$GivenName = Read-Host "Enter the users first name"
$Surname = Read-Host "Enter the users surname"
$Org = Read-Host "Enter users agency"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@communities.wa.gov.au"
$Server = "vwpdcrw0003.dhw.wa.gov.au"
$DisplayName = "$GivenName $Surname"
$Name = $SamAccountName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"
$Group = "External Domain Users","APP_THRIMS_USERS"
$Password = ConvertTo-SecureString "FastAaron12" -AsPlainText -Force

$ExternalPath = "OU=External_Domain_Users,OU=WXP_DMZ,OU=Housing,DC=dhw,DC=wa,DC=gov,DC=au"


New-ADUser -GivenName $GivenName -Surname $Surname `
-SamAccountName $SamAccountName -DisplayName $DisplayName `
-Name $Name -UserPrincipalName $UserPrincipalName -Path $ExternalPath `
-PasswordNeverExpires $false -AccountPassword $Password -Enabled $True `
-ChangePasswordAtLogon $True -Server $Server -Office $Org `
-Company $Org
Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $Group -Server $Server

Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External Thrims'} -Server $Server

$PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server

Set-ADUser -Identity $SamAccountName -Replace @{info="$Notes;"} -Server $Server

Write-Host = Get-ADUser $SamAccountName | Select-Object DisplayName,UserPrincipalName,SamAccountName
