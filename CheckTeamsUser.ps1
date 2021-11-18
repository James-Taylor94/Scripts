$getsessions = Get-PSSession | Select-Object -Property State, Name
$isconnected = (@($getsessions) -like '@{State=Opened; Name=SfBPowerShellSessionViaTeamsModule*').Count -gt 0
Write-Host "Checking for active SFBOnline connections..." -ForegroundColor Yellow
If ($isconnected -ne "True") {
    Try { 
    Write-Host "No active connection found, establishing new connection to SFBOnline" -ForegroundColor Yellow
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession -AllowClobber
} Catch {
    Write-Host "SFBOnline failed to connect, exiting script." -ForegroundColor Red
    Exit
}
}
Write-Host "Connection established to SFBOnline" -ForegroundColor Green

$UPN = Read-Host "Enter the users UPN"

Get-CsOnlineUser -Identity $UPN | Select-Object -Property OnPremLineURI,EnterpriseVoiceEnabled,HostedVoicemail,TenantDialPlan,OnlineVOiceRoutingPolicy,TeamsCallingPolicy,CallingLineIdentity

Write-Host "Settings should match the following:

OnPremLineURI            : tel:+618xxxxxxxx
EnterpriseVoiceEnabled   : True
HostedVoiceMail          : True
TenantDialPlan           : DoCDialPlan
OnlineVoiceRoutingPolicy : AU-WA-National
TeamsCallingPolicy       : AllowCalling
CallingLineIdentity      : Anonymous"


$UserCheck = Read-Host "Do you want to reapply settings to this user? (Y\N)"
if ($UserCheck -like 'y') {
    Set-CsUser -Identity $UPN -EnterpriseVoiceEnabled $True -HostedVoicemail $True
    Grant-CsTenantDialPlan -PolicyName tag:DoCDialPlan -Identity $UPN
    Grant-CsOnlineVOiceRoutingPolicy -PolicyName "AU-WA-National" -Identity $UPN
    Grant-CsTeamsCallingPolicy -PolicyName AllowCalling -Identity $UPN
    Write-Host "Reapplied settings to $UPN" -ForegroundColor Green
} elseif ($UserCheck -like 'n') {
    exit
}