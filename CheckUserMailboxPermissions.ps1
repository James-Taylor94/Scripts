<#
.SYNOPSIS
    Used to query all mailboxes in Exchange Online to determine what mailboxes a particular user has access to
.DESCRIPTION
    This script is designed to get a list of all active mailboxes from EXO and then check to see what mailboxes a particular user has access to as well as their level of access
.NOTES
    Generated On: 22/04/2020
    Author: Matthew Heuer
#>

#Enter the users email address
$User = Read-Host "Enter the users email address"

Try {
    Write-Host "Querying Exchange Online for active mailboxes..." -ForegroundColor Yellow
    $MailboxQuery = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited
    Write-Host "Search complete!" -ForegroundColor Green
} Catch {
    Write-Host "Failed to query Exchange Online, please try again"
}

Try {
    Write-Host "Checking $User permissions" -ForegroundColor Yellow
    $MailboxQuery | Get-MailboxPermission -User $User | Select-Object -ExpandProperty Identity
} Catch {
    Write-Host "Failed to query Exchange Online, please try again"
}