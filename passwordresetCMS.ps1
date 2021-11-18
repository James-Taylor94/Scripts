import-module activedirectory

$mycreds = Get-Credential
$accounts = "OracleCMS7","OracleCMS8","OracleCMS9","OracleCMS10","OracleCMS11"
foreach ($SAM in $accounts)
{
	Set-ADAccountPassword $SAM -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "FastAaron12" -Force) -Credential $mycreds
}