<#
.SYNOPSIS
    This script is designed to create RSP accounts
.DESCRIPTION
    
.NOTES
    Generated On: 10/05/2021
    Author: James Taylor
#>

Import-Module ActiveDirectory
$AccountType = Read-Host "What is the organistaion? (Marra Worra Worra, Emama Nguda, Mowanjum, Pilbara Meta Maya, CHL - KUN, CHL - KAL, Ngaanyatjarra"
$RITM = Read-Host "Enter the RITM number of the ticket"

$SamAccountName = Read-Host "Enter the SamAccountName"
$USER = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty UserPrincipalName
if ($USER) {
    Write-Host "$USER already has taken $SamAccountName" -ForegroundColor Red
}
else {
    Write-Host "$SamAccountName is availble" -ForegroundColor Green
}

$GivenName = Read-Host "Enter the users first name"
$Surname = Read-Host "Enter the users surname"
$Org = Read-Host "Enter the organisation"
$JobTitle = Read-Host "Enter the users job title"
$Manager = Read-Host "Enter the managers (person who submitted the request) username"
$ExternalEmail = Read-Host "Enter the external email address"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@communities.wa.gov.au"
$Server = "vwpdcrw0003.dhw.wa.gov.au"
$DisplayName = "$GivenName $Surname"
$Name = $DisplayName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"

$AccountPassword = ConvertTo-SecureString "FastAaron12" -AsPlainText -Force

$MWW_Group = "APP_POWERBI_RLS_RSP-MWW-DER_USERS", "Role-User-External-RSP.MarraWorraWorra", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$EmamaNgudaGroup = "APP_POWERBI_RLS_RSP-EN-DER_USERS", "Role-User-External-RSP.EmamaNguda", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$MowanjumGroup = "APP_POWERBI_RLS_RSP-MAC-DER_USERS", "Role-User-External-RSP.Mowanjum", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$MetaMayaGroup = "APP_POWERBI_RLS_RSP-PMM-HED_USERS", "Role-User-External-RSP.PilbaraMetaMaya", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$CommunityHousingKununurraGroups = "APP_POWERBI_RLS_RSP-CHL-KUN_USERS", "Role-User-External-RSP.CommunityHousingLTD", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$CommunityHousingKalgoorlieGroups = "APP_POWERBI_RLS_RSP-CHL-KAL_USERS", "Role-User-External-RSP.CommunityHousingLTD", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"
$NgaanyatjarraGroups = "APP_POWERBI_RLS_RSP-NG-KAL_USERS", "Role-User-External-RSP.Ngaanyatjarra", "External Domain Users", "App-Microsoft-Office365-Communities.SecurityBaseline","Auth-MFA.Azure.ExternalRegistration.Allow"

$Path = "OU=External_Domain_Users,OU=WXP_DMZ,OU=Housing,DC=dhw,DC=wa,DC=gov,DC=au"

If ($AccountType -like "Marra Worra Worra") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MWW_Group -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "Emama Nguda") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $EmamaNgudaGroup -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "Mowanjum") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MowanjumGroup -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "Pilbara Meta Maya") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MetaMayaGroup -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "CHL - KUN") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $CommunityHousingKununurraGroups -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "CHL - KAL") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $CommunityHousingKalgoorlieGroups -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
elseif ($AccountType -like "CHL - KAL") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $CommunityHousingKalgoorlieGroups -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
} elseif ($AccountType -like "Ngaanyatjarra") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Org `
        -Company $Org -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $NgaanyatjarraGroups -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
} 
else {
    Add-LogEntry -LogLevel Error -LogEntry "Account type variable not valid, exiting script"
    Exit
}
Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External RSP' } -Server $Server
Set-ADUser -Identity $SamAccountName -Replace @{info = "$Notes;" } -Server $Server

Write-Host "$SamAccountName has been created"