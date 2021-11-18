#This script will unlock a file locked for editing on a network share NOT Sharepoint
#Full path of folder (\\dhw.wa.gov.au\CorporateData\etc.) and file with extension (NigNogs.docx) must be provided when prompted
#V1.0 Geoff N
#FUNCTIONS
Function Add-LogEntry {
    Param([ValidateSet("Error", "Info", "Warning")][String]$LogLevel, [String]$LogEntry)
    $TimeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $StreamWriter = New-Object System.IO.StreamWriter -ArgumentList ([IO.File]::Open($LogFile, "Append"))
    $StreamWriter.WriteLine("$TimeStamp - $LogLevel - $LogEntry")
    if ($LogLevel -eq 'Error') {
        Write-Host "$LogEntry" -ForegroundColor Red
    }
    elseif ($LogLevel -eq 'Warning') {
        Write-Host "$LogEntry" -ForegroundColor Yellow
    }
    elseif ($LogLevel -eq 'Info') {
        Write-Host "$LogEntry" -ForegroundColor Green
    }
    $StreamWriter.Close()
}
$Today = Get-Date -Format "ddMMyyyy"
$Logfile = "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Logs\UnlockFile_$Today.log"
$Admin = $env:UserName
#VARIABLES
$Folder = Read-Host -Prompt "Enter the Full Path of the folder containing the file"
$File = Read-Host -Prompt "Enter the file name including the file extension"
$ElLocko = "~$"
#START
CD $Folder
Add-LogEntry -LogLevel Info -LogEntry "$env:Username Changed Directory to $Folder"
Delete "$ElLocko$File" 
Add-LogEntry -LogLevel Info -LogEntry "$env:Username Deleted $File"
Write-Host "Clippety Clocked $File has been unlocked"
Add-LogEntry -LogLevel Info -LogEntry "Process Completed"