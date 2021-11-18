#Connects to Skype for Business Online
Import-Module MicrosoftTeams
Try {
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession
} Catch {
    Write-Host "Unable to connect to Skype for Business Online. $($_.Exception.Message)."
    Exit
}