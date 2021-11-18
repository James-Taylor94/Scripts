<#
.SYNOPSIS
    Used to re-enable external Traige\Fusion accounts, add the required groups and move to the appropriate OU.
.DESCRIPTION
    The script will query a list of CSV exports created from the DisableAccount.ps1 script and import those groups into the AD object. If no export is found it will add the default groups
    Run this on the CPFS Jumphost dc01sv732.ad.dcd.wa.gov.au
.NOTES
    Generated On: 10/05/2021
    Author: Matthew Heuer
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
$Logfile = "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Logs\Enable-DCDExternalAccountLog_$Today.txt"

$SAM = Read-Host "Enter the sAMAccountname of the user you want to re-enable"
$AccountType = Read-Host "What kind of account are you enabling? (Triage/Fusion)"
$RITM = Read-Host "Enter the RITM number of the ticket"
$EndDate = Read-Host "Enter the account expiration date (Enter date as DD/MM/YYYY)"
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Re-Enabled $Today $RITM $Admin"
$Server = 'dc01sv962.ad.dcd.wa.gov.au'

$USER = Get-ADUser -Identity $SAM | Select-Object -ExpandProperty UserPrincipalName
    if ($USER) {
        Add-LogEntry -LogLevel Info -LogEntry "Found disabled account $USER with username: $SAM"
     } else {
        Add-LogEntry -LogLevel Warning -LogEntry "No user in AD found using the username: $SAM"
        Exit
     }

$Confirm = Read-Host "Do you want to re-enable this account? (Y\N)"
if ($Confirm -like 'y') {
    #Ignore this
} 
elseif ($Confirm -like 'n') {
    exit
}

Set-ADUser -Identity $SAM -Enabled $true -AccountExpirationDate $EndDate -Server $Server
$GUID = Get-ADUser -Identity $SAM | Select-Object -ExpandProperty ObjectGUID
if ($AccountType -like 'Triage') {
    Move-ADObject -Identity $GUID -TargetPath "OU=DVIR,OU=NGO,OU=External Users,OU=Core Infrastructure,DC=ad,DC=dcd,DC=wa,DC=gov,DC=au"    
} elseif ($AccountType -like 'Fusion') {
    Move-ADObject -Identity $GUID -TargetPath "OU=FSN,OU=NGO,OU=External Users,OU=Core Infrastructure,DC=ad,DC=dcd,DC=wa,DC=gov,DC=au"
} else {
    Add-LogEntry -LogLevel Error -LogEntry 'Input not valid exiting script'
    Exit
}

Add-LogEntry -LogLevel Info -LogEntry "Checking for groups backups..."
$ExportFile = Get-ChildItem -Path 'C:\Temp\MHeuer\Exports' -Filter *$SAM* | Where-Object {$_.Name -like '*.csv'} | Select-Object -ExpandProperty Name
if ($ExportFile) {
    Write-Host "$ExportFile found, adding groups from backup"
    $GroupImport = Import-CSV "C:\Temp\MHeuer\Exports\$ExportFile"
    $GroupImport = $GroupImport | Where-Object {$_.Name -ne 'Domain Users'}
    $GroupImport | ForEach-Object {
        Add-ADGroupMember -Identity $SAM -MemberOf $_.name
    } 
} else {
    Write-Host "No backup found, adding standard groups"
    If ($AccountType -eq 'Triage') {
        Add-ADGroupMember -Identity GBL_FSN_ThirdParty_Users -MemberOf $SAM
    } elseif ($AccountType -eq 'Fusion') {
        Add-ADGroupMember -Identity GBL_DVIR_ThirdParty_Users -MemberOf $SAM
    }
}

if ($INFO = (Get-ADUser -Identity $SAM -Properties info).info) {
    Set-ADUser -Identity $SAM -Replace @{info="$INFO`r`n$Notes;"}
} else {
    Set-ADUser -Identity $SAM -Replace @{info="$Notes;"}
}

$UserEnableCheck = Get-ADUser $SAM -Properties * -Server $Server | Select-Object -Property SamAccountName,UserPrincipalName,Enabled

if ($UserEnableCheck) {
    Write-Host "$SAM successfully re-enabled"
    $UserEnableCheck
} else {
    Write-Host "$SAM failed to re-enable, try again"
    Exit
}