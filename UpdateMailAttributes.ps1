Import-Module  ActiveDirectory

$samAccountname = read-host "Please enter the username"
$targetAddress = read-host "Please enter the target address"
$mailNickname = $SamAccountname

Set-AdUser $SamAccountname -Replace @{msExchRecipientTypeDetails="2147483648"}
Set-AdUser $SamAccountname -Replace @{msExchRecipientDisplayType="-2147483642"}
Set-AdUser $SamAccountname -Replace @{msExchRemoteRecipientType="3"}
Set-AdUser $SamAccountname -Replace @{mail="Trainee.Fifty-six@communities.wa.gov.au"}
Set-AdUser $SamAccountname -Replace @{mailNickname=$mailnickname}
Set-AdUser $SamAccountname -Replace @{targetAddress=$targetAddress}