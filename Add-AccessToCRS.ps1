#==============================================================================
# Add-AccessToCRS.ps1 - adds users to the DLs for the children's rooms
# 
# Version: 1.0
# Created: 11/05/2021
# Modified: 03/08/2021
# Deployed: 08/08/2021
# Author: James Britton [JDB]
# Purpose: For, but not limited to, the Kinetic IT Service Desk
# team for Dept of Communities.
#==============================================================================

<# 
==============================
Start Changelog
==============================
V0.1
-   Created initial script 11/05/2021
V1.0
-   Finalizing script 12/05/2021
-   Approved for deployment. 
==============================
End Changelog
============================== 
#>

#====================================================================
#Functions
#====================================================================

<#  I have attempted multiple times and techniques to catch and handle 
    errors/exceptions from the Add-DistributionGroup cmdlet.
    It doesn't seem to be possible for some reason. Drives me wild.
    Could be due to this being on ExchangeOnline?
    So we have to just put up with errors being on-screen/unhandled.
    Then verify the user was added successfully to all DLs post-hoc. #>

function Add-AccessToChildrensRoom {
    param ([Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string] $User)
    
    $Sessions = (Get-PSSession).computername # Checking for existing EXO sessions. If none, connect.
    If (!($Sessions -like 'outlook.office365.com')) {
        Connect-ExchangeOnline
    }

    Write-Host "Confirming $User is a valid user/mailbox."
    if (Get-Mailbox $User) {
        Write-Host "$User exists - proceeding" -ForegroundColor Green -BackgroundColor Black
    }
    else {
        Write-Warning "Unable to determine if $User is a real user, please double check the primary SMTP address/UPN."
        Write-Warning "Exiting."
        Exit
    }

    $DistributionGroups = "Right-EXOCalendar-FremantleChildrensWP1.BookinPolicy,Right-EXOCalendar-FremantleChildrensWP2.BookinPolicy,Right-EXOCalendar-FremantleChildrensWP3.BookinPolicy,Right-EXOCalendar-FremantleChildrensWP4.BookinPolicy,Right-EXOCalendar-FremantleChildrensWP5.BookinPolicy,Right-EXOCalendar-FremantleChildrensWP6.BookinPolicy,Right-EXOCalendar-FreoNorthChildrensWP1.BookinPolicy,Right-EXOCalendar-FreoNorthChildrensWP2.BookinPolicy".split(",")
    $PercentComplete = 0
    foreach ($DistributionGroup in $DistributionGroups) {
        Write-Host "Attempting to add $User to $DistributionGroup" -BackgroundColor Black -ForegroundColor Magenta
        Add-DistributionGroupMember -Identity $DistributionGroup -Member $User -Verbose -Confirm:$false
        $PercentComplete += 12.5
        Write-Progress -Activity "Adding user to DLs" -PercentComplete $PercentComplete
        Write-Host "----------------" -BackgroundColor Black -ForegroundColor Magenta
    }

    Write-Host "Finished attempt to add $User to the Children's Room's distribution groups." -BackgroundColor Black -ForegroundColor Yellow

    Start-Sleep -Seconds 7 # Give things a moment to update.
    Write-Host "Confirming user is a member of all 8 DLs:" # Checks to see if the user is listed as a DG member for each DG. 
    foreach ($DistributionGroup in $DistributionGroups) {
        if (!(Get-DistributionGroupMember $DistributionGroup | Select-Object primarysmtpaddress) -cmatch $User) {
            Write-Host "$User seemingly is not a member of $DistributionGroup - may just require time to synchronize, consult above for errors." -ForegroundColor Red -BackgroundColor Black
        }
        else {
            Write-Host "$User is a member of $DistributionGroup." -ForegroundColor Green -BackgroundColor Black
        }
    }

    Write-Host "Please consult output for further information or errors."
}

#====================================================================
# Main section. 
#====================================================================

$OldWindowTitle = $host.UI.RawUI.WindowTitle
$host.UI.RawUI.WindowTitle = "Add-AccessToCRS :: Adding user to distribution groups."
Write-Host "Adding supplied user to distribution groups for access to the Children's Rooms..." -BackgroundColor Black -ForegroundColor Yellow

if ($args.count -lt 1) {
    Write-Host "No UPN/SMTP address supplied. You should call this script with the user's email address after it." -ForegroundColor Red -BackgroundColor Black
    $User = Read-Host -Prompt "Supply user's UPN:" # We'll be nice and let them supply the UPN anyway.
    Add-AccessToChildrensRoom -User $User
} else {
    Add-AccessToChildrensRoom -User $args[0]
}

$host.UI.RawUI.WindowTitle = $OldWindowTitle
Read-Host "Press enter to exit."

<#  ====================================================================
    .SYNOPSIS
    Adds the supplied user to the 8 distribution groups required for access to the Fremantle Newman Court
    Children's Rooms. Then confirms they have been added.
    Licensed under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html

    .DESCRIPTION
    Adds the supplied user to the 8 distribution groups required for access to the Fremantle Newman Court
    Children's Rooms. Then confirms they have been added. To use this utility:
    > .\Add-AccessToCRS.ps1 example.person@communities.wa.gov.au
    (Not case sensitive.)

    .EXAMPLE
    > .\Add-AccessToCRS.ps1 example.person@communities.wa.gov.au
    (Not case sensitive.)

    .INPUTS
    None.

    .LINK
    By James Duncan Britton.
    LinkedIn:
    https://au.linkedin.com/
    GitHub:
    https://github.com/jdbritton

    .NOTES
    This script was originally created by James Duncan Britton, for the Service Desk for 
    the WA Department of Communities. 
    This script is released under the GNU GPL 3.0. http://www.gnu.org/licenses/gpl-3.0.en.html
    ... Unless my bosses tell me otherwise.
==================================================================== #>