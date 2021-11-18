Import-Module ActiveDirectory

$mycreds = Get-Credential
$accounts = "UONET1","UTWOT1","UTHRET1","UFOURT1","UFIVET1","USIXT1","USEVET1","UEIGHT1","UNINET1","UTENT1","UELEVT1","UTWELT1","UTHIRT1","UFOURT2","UFIFTT1","USIXTT1","USEVET2","UEIGHT2","UNINET2","UTWENT0","UTWENT1","UTWENT2","UTWENT3","UTWENT4"
foreach ($SAM in $accounts)
{
    Set-ADAccountPassword $SAM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Objective5" -Force) -Credential $mycreds
}