<#
.SYNOPSIS
    This script is designed to create Fusion and Triage accounts
.DESCRIPTION
    
.NOTES
    Generated On: 02/05/2021
    Author: Matt Heuer\James Taylor
#>
Import-Module ActiveDirectory

$AccountType = Read-Host "What account are you creating (Fusion\Triage)"
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
$UserPrincipalName = "$SamAccountName@ad.dcd.wa.gov.au"
$Server = "dc01sv962.ad.dcd.wa.gov.au"
$DisplayName = "$GivenName $Surname"
$Name = $DisplayName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"

$FusionPassword = ConvertTo-SecureString "1NewFusion" -AsPlainText -Force
$TriagePassword = ConvertTo-SecureString "1NewTriage" -AsPlainText -Force

$FusionPath = "OU=DVIR,OU=NGO,OU=External Users,OU=Core Infrastructure,DC=ad,DC=dcd,DC=wa,DC=gov,DC=au"
$TriagePath = "OU=FSN,OU=NGO,OU=External Users,OU=Core Infrastructure,DC=ad,DC=dcd,DC=wa,DC=gov,DC=au"

If ($AccountType -like "Fusion") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $FusionPath `
    -PasswordNeverExpires $True -AccountPassword $FusionPassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org
    Add-ADGroupMember -Identity GBL_FSN_ThirdParty_Users -Members $SamAccountName
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External Fusion'}
} elseif ($AccountType -like "Triage") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $TriagePath `
    -PasswordNeverExpires $True -AccountPassword $TriagePassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org
    Add-ADGroupMember -Identity GBL_DVIR_ThirdParty_Users -Members $SamAccountName
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External DVIR'}
}

Set-ADUser -Identity $SamAccountName -Replace @{info="$Notes;"}

Write-Host = Get-ADUser $SamAccountName | Select-Object DisplayName,UserPrincipalName,SamAccountName