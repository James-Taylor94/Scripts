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
$Org = Read-Host "Enter the organisation"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@james.local"
$Server = "james.local"
$DisplayName = "$GivenName $Surname"
$Name = $DisplayName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"

$AccountPassword = ConvertTo-SecureString "FastAaron12" -AsPlainText -Force

$MWW_Group = "APP_POWERBI_RLS_RSP-MWW-DER_USERS","Role-User-External-RSP.MarraWorraWorra","External Domain Users","App-Microsoft-Office365-Communities.SecurityBaseline"
$EmamaNgudaGroup = "APP_POWERBI_RLS_RSP-EN-DER_USERS","ole-User-External-RSP.EmamaNguda","External Domain Users","App-Microsoft-Office365-Communities.SecurityBaseline"
$MowanjumGroup = "APP_POWERBI_RLS_RSP-MAC-DER_USERS","Role-User-External-RSP.Mowanjum","External Domain Users","App-Microsoft-Office365-Communities.SecurityBaseline"
$MetaMayaGroup = "APP_POWERBI_RLS_RSP-PMM-HED_USERS","Role-User-External-RSP.PilbaraMetaMaya","External Domain Users","App-Microsoft-Office365-Communities.SecurityBaseline"

$Path = "OU=ExternalDomainUsers,OU=Accounts,DC=james,DC=local"

If ($AccountType -like "Marra Worra Worra") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
    -AccountPassword $AccountPassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org `
    -Company $Org
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MWW_Group -Server $Server
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External RSP'}

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
} elseif ($AccountType -like "Emama Nguda") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
    -AccountPassword $AccountPassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org `
    -Company $Org
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $EmamaNgudaGroup -Server $Server
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External RSP'} -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
} elseif ($AccountType -like "Mowanjum") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
    -AccountPassword $AccountPassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org `
    -Company $Org
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MowanjumGroup -Server $Server
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External RSP'} -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
} elseif ($AccountType -like "Pilbara Meta Maya") {
    New-ADUser -GivenName $GivenName -Surname $Surname `
    -SamAccountName $SamAccountName -DisplayName $DisplayName `
    -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
    -AccountPassword $AccountPassword -Enabled $True `
    -ChangePasswordAtLogon $True -Server $Server -Office $Org `
    -Company $Org
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $MetaMayaGroup -Server $Server
    Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External RSP'} -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}

Set-ADUser -Identity $SamAccountName -Replace @{info="$Notes;"} -Server $Server

Write-Host = Get-ADUser $SamAccountName | Select-Object DisplayName,UserPrincipalName,SamAccountName