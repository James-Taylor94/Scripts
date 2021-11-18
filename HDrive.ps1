$SAN = Read-Host "Please enter samaccountname"
$User = Get-ADUser -Identity $SAN -Properties homeDirectory
$HDrivebefore = $User.HomeDirectory

If ($HDrivebefore -like '*HousingUsers\AtoL*'){
    $HDrive = "\\ho-pth-san01\housingusers$\$SAN"
} else {
    $HDrive = "\\ho-pth-san01\housingusers_MtoZ$\$SAN"
}

New-Item -Path $HDrive -Type Directory -Force
$acl = Get-Acl $HDrive
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("HEAD_OFFICE\$SAN", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($Ar)
$acl | Set-Acl $HDrive