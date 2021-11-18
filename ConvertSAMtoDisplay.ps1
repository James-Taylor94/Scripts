import-module activedirectory

Get-Content '#Import Path#' |
ForEach-Object {Get-ADUser $_ -Properties DisplayName}  | Select-Object  samaccountname,DisplayName |
Export-Csv '#Export Path#' -NoTypeInformation