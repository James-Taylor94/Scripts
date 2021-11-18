<#
.SYNOPSIS
    Used to re-enable external accounts, add the backed up groups and move to the appropriate OU.
.DESCRIPTION
    The script will query a list of CSV exports created from the DisableAccount.ps1 script and import those groups into the AD object. If no export is found it will add the default groups
.NOTES
    Generated On: 08/05/2021
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
$Logfile = "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Logs\Enable-DHWAccountLog_$Today.txt"

$SAM = Read-Host "Enter the sAMAccountname of the user you want to re-enable"
$RITM = Read-Host "Enter the RITM number of the ticket"
$EndDate = Read-Host "Enter the account expiration date (Enter date as DD/MM/YYYY)"
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Re-Enabled $Today $RITM $Admin"
$Server = 'vwpdcrw0003.dhw.wa.gov.au'
$AccountPassword = "FastAaron12"

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
Set-ADAccountPassword -Identity $SAM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $AccountPassword -Force)
$GUID = Get-ADUser -Identity $SAM | Select-Object -ExpandProperty ObjectGUID
Move-ADObject -Identity $GUID -TargetPath "OU=External_Domain_Users,OU=WXP_DMZ,OU=Housing,DC=dhw,DC=wa,DC=gov,DC=au"

Add-LogEntry -LogLevel Info -LogEntry "Checking for groups backups..."
$ExportFile = Get-ChildItem -Path '\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Exports' -Filter *$SAM* | Where-Object {$_.Name -like '*.csv'} | Select-Object -ExpandProperty Name
if ($ExportFile) {
    Add-LogEntry -LogLevel Info -LogEntry "$ExportFile found, adding groups from backup"
    $GroupImport = Import-CSV "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Exports\$ExportFile"
    $GroupImport = $GroupImport | Where-Object {$_.Name -ne 'External Domain Users'}
    $GroupImport | ForEach-Object {
        Add-ADPrincipalGroupMembership -Identity $SAM -MemberOf $_.name
    } 
} else {
    Add-LogEntry -LogLevel Warning -LogEntry "No backup found"
    Exit
}


if ($INFO = (Get-ADUser -Identity $SAM -Properties info).info) {
    Set-ADUser -Identity $SAM -Replace @{info="$INFO`r`n$Notes;"}
} else {
    Set-ADUser -Identity $SAM -Replace @{info="$Notes;"}
}

$UserEnableCheck = Get-ADUser $SAM -Properties * -Server $Server | Select-Object -Property SamAccountName,UserPrincipalName,Enabled

if ($UserEnableCheck) {
    Add-LogEntry -LogLevel Info -LogEntry "$SAM successfully re-enabled"
    $UserEnableCheck
} else {
    Add-LogEntry -LogLevel Error -LogEntry "$SAM failed to re-enable, try again"
    Exit
}