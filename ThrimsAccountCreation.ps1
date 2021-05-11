<#
.SYNOPSIS
    This script is designed to create Thrims accounts
.DESCRIPTION
    
.NOTES
    Generated On: 03/05/2021
    Author: James Taylor
#>
Import-Module ActiveDirectory

Function Add-LogEntry {
    Param([ValidateSet("Error", "Info", "Warning")][String]$LogLevel, [String]$LogEntry)
    $TimeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $StreamWriter = New-Object System.IO.StreamWriter -ArgumentList ([IO.File]::Open($LogFile, "Append"))
    $StreamWriter.WriteLine("$TimeStamp - $LogLevel - $LogEntry")
    if ($LogLevel -eq 'Error') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Red
    } elseif ($LogLevel -eq 'Warning') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Yellow 
    } elseif ($LogLevel -eq 'Info') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Green
    }
    $StreamWriter.Close()
}

$Today = Get-Date -Format "ddMMyyyy"
$Logfile = "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Logs\ThrimsAccountCreationLog_$Today.txt"

$RITM= Read-Host "Enter the RITM number of the ticket"
 
$SamAccountName = Read-Host "Enter the SamAccountName"
$USER = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty UserPrincipalName
    if ($USER) {
        Add-LogEntry -LogLevel Warning -LogEntry "$USER already has taken $SamAccountName"
     } elseif (!$USER) {
        Add-LogEntry -LogLevel Info -LogEntry "$SamAccountName is availble"
    }

$GivenName = Read-Host "Enter the users first name"
$Surname = Read-Host "Enter the users surname"
$Org = Read-Host "Enter users agency"
$ExternalEmail = Read-Host "Enter the external email address"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@communities.wa.gov.au"
$Server = "vwpdcrw0003.dhw.wa.gov.au"
$DisplayName = "$GivenName $Surname"
$Name = $SamAccountName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"
$Group = "External Domain Users","APP_THRIMS_USERS","App-Microsoft-Office365-Communities.SecurityBaseline"
$Password = ConvertTo-SecureString "FastAaron12" -AsPlainText -Force

$ExternalPath = "OU=External_Domain_Users,OU=WXP_DMZ,OU=Housing,DC=dhw,DC=wa,DC=gov,DC=au"

Add-LogEntry -LogLevel Info -LogEntry "Creating account..."
New-ADUser -GivenName $GivenName -Surname $Surname `
-SamAccountName $SamAccountName -DisplayName $DisplayName `
-Name $Name -UserPrincipalName $UserPrincipalName -Path $ExternalPath `
-PasswordNeverExpires $false -AccountPassword $Password -Enabled $True `
-ChangePasswordAtLogon $True -Server $Server -Office $Org `
-Company $Org -EmailAddress $ExternalEmail
Add-ADPrincipalGroupMembership $SamAccountName -MemberOf  $Group -Server $Server

Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External Thrims'} -Server $Server

$PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
Set-ADUser $SamAccountName -replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Server $Server
Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server

Set-ADUser -Identity $SamAccountName -Replace @{info="$Notes;"} -Server $Server

Add-LogEntry -LogLevel info -LogEntry "Script ran by $Admin"
