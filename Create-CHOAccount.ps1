<#
.SYNOPSIS
    This script is designed to create CHO accounts
.DESCRIPTION
    
.NOTES
    Generated On: 10/08/2021
    Author: James Taylor
#>

Import-Module ActiveDirectory

Function Add-LogEntry {
    Param([ValidateSet("Error", "Info", "Warning")][String]$LogLevel, [String]$LogEntry)
    $TimeStamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $StreamWriter = New-Object System.IO.StreamWriter -ArgumentList ([IO.File]::Open($LogFile, "Append"))
    $StreamWriter.WriteLine("$TimeStamp - $LogLevel - $LogEntry")
    if ($LogLevel -eq 'Error') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Red
    }
    elseif ($LogLevel -eq 'Warning') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Yellow 
    }
    elseif ($LogLevel -eq 'Info') {
        Write-Host "$TimeStamp - $LogLevel - $LogEntry" -ForegroundColor Green
    }
    $StreamWriter.Close()
}
$Today = Get-Date -Format "ddMMyyyy"
$Logfile = "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Logs\CHOAccountCreationLog_$Today.log"

Write-Host "Script to create a CHO Account"
$RITM = Read-Host "Enter the RITM number of the ticket"

$SamAccountName = Read-Host "Enter the SamAccountName"
$USER = Get-ADUser -Identity $SamAccountName | Select-Object -ExpandProperty UserPrincipalName
if ($USER) {
    Write-Host "$USER already has taken $SamAccountName" -ForegroundColor Red
    Exit
}
else {
    Write-Host "$SamAccountName is availble" -ForegroundColor Green
}

$GivenName = Read-Host "Enter the users first name"
$Surname = Read-Host "Enter the users surname"
$JobTitle = Read-Host "Enter the users job title"
$Manager = Read-Host "Enter the managers (person who submitted the request) username"
$ExternalEmail = Read-Host "Enter the external email address"
$Phone = Read-Host "Enter the phone number"
$Organisation = Read-Host "Enter the organisation"

### Static Variables ###
$UserPrincipalName = "$SamAccountName@communities.wa.gov.au"
$Server = "ho-pth-dc03"
$DisplayName = "$GivenName $Surname"
$Name = $DisplayName
$Admin = $env:UserName
$Today = Get-Date -Format "dd/MM/yyyy"
$Notes = "Created $Today $RITM $Admin"
$EndDate = (get-date).AddYears(1)

$AccountPassword = ConvertTo-SecureString "FastAaron12" -AsPlainText -Force

### Organisation Unit ###
$Path = "OU=External_Domain_Users,OU=WXP_DMZ,OU=Housing,DC=dhw,DC=wa,DC=gov,DC=au"

### CHO Organisation AD Groups ###
$CHO = 'App-Microsoft-Office365-EMS-E3','App-WVD-RemoteApp.05.HABITAT-External.P','Role-User-External-CHO','Auth-MFA.Azure.ExternalRegistration.Allow','Auth-MFA.SSPR.Azure.RegistrationAllowed','External Domain Users'

try {
    New-ADUser -GivenName $GivenName -Surname $Surname `
        -SamAccountName $SamAccountName -DisplayName $DisplayName `
        -Name $Name -UserPrincipalName $UserPrincipalName -Path $Path `
        -AccountPassword $AccountPassword -Enabled $True `
        -ChangePasswordAtLogon $True -Server $Server -Office $Organisation `
        -Company $Organisation -EmailAddress $ExternalEmail -Title $JobTitle -Manager $Manager `
        -AccountExpirationDate $EndDate -OfficePhone $Phone
    Add-ADPrincipalGroupMembership $SamAccountName -MemberOf $CHO -Server $Server

    $PrimaryGroup = Get-ADGroup "External Domain Users" -properties @("primaryGroupToken")
    Set-ADUser $SamAccountName -replace @{primaryGroupID = $PrimaryGroup.primaryGroupToken } -Server $Server
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Server $Server
}
catch {
    $ErrorMessage = $_
    Add-LogEntry -LogLevel Error -LogEntry "Unable to create new user account, error recieved $ErrorMessage"
    Exit   
}

Set-ADUser -Identity $SamAccountName -Replace @{employeeType = 'External CHO' } -Server $Server
Set-ADUser -Identity $SamAccountName -Replace @{info = "$Notes;" } -Server $Server

Add-LogEntry -LogLevel info -LogEntry "$SamAccountName has been created"
Add-LogEntry -LogLevel info -LogEntry "Script ran by $Admin"
# SIG # Begin signature block
# MIIVEwYJKoZIhvcNAQcCoIIVBDCCFQACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFOPtIyQteomNzvXV5qWQNawK
# YXOgghJRMIIFFzCCAv+gAwIBAgIQdexlXsRJKYlLPymgWWJPNjANBgkqhkiG9w0B
# AQwFADAeMRwwGgYDVQQDExNDb21tdW5pdGllcy1Sb290LUNBMB4XDTE5MTExMzA1
# NDUzNloXDTQ0MTExMzA1NTUzNVowHjEcMBoGA1UEAxMTQ29tbXVuaXRpZXMtUm9v
# dC1DQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAKxjEMdd7dn1ddh4
# 5wogOaUANHq8HzdbNEUyGPs6BeWPdcisU7yME7oAI8Y0tJJAQC5ORvpBmAy6oEsP
# HMsjYfbwnVzlfULeGArEJ3YND+3oMIbH9tSb/XyWhj/crsga0vIMVxaEjnWsuzAU
# v/nmD9OvqPBMI9GuxQ8Ap1oNASu1hvFS0aKsDBYkf7l49UoAAsH7kBrIEkGVnTtN
# 2cilU2nkL5zYvsdJ+kQurJ0oQ3gViGZO9YlNvlro7kQ8VW8LHSuMBJhdA4adhHGH
# 49NBTnnqyf5iUz6ou9YI0pmS2qJsRg2aJ5rOWRDahkdPVKTZ2R/0z5zEqjM+Ddfn
# s5TY/AHLv2viFaAIlUEe+6l0g966fqoftSPTOoUnNqhXk6Z4mwRBiYEEcFfgtKuT
# wux43B9wyzukepcyrAq+ahS9zG/M6rf8jYxxGaIPX9Ut8CHwBCnP7WuhVppKJ/cU
# 9ljvqLmNwDaeshHDdKJfcamiAUFLsnCb6F0lJye+z5STheEHseMVVoodE7eIpJed
# p3Lj3bSEaXF+7ICOu0dSBiMpzFstWHIpY1fwn+IXyaxAqSYgR3kGAVkV3DYqbi3F
# gVgrlY6/PHgHZKZHEmoifooz2lqsw+U9l1JcVSllUk8lgY4mIytfohXOKZ6jaBFl
# cERButahADfcFw0ED9DKH6gvWclLAgMBAAGjUTBPMAsGA1UdDwQEAwIBhjAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBRxvkgmDMIPefzjaQ4OQs1oG7xgqjAQBgkr
# BgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEADXKOHWOrl68R96IW2Q7a
# mdYHEv1Gk53HaOO4Pq9jnGjXMmRl9gD2tBfWHoGTVKIntLo2gDI/+K2jgSwfgbMs
# M65KVacQT7iZ67oD6SNc4gkI9rJOZjsjaajOuz0x56GFfuqDewaL1NCbzmRoIPOO
# mwTQHLeM1k9pfJHmF5yh10tnmnfR+vst/0W7iMoLGht19mhTz5Lzcp1Nx/AMO8H6
# eaGwCPnu+37hMRQDr7uswvYmDW6cTKPd+2QODT/kHaTrelatM4xSf8Xy1FQF7JsE
# uoJILm1VDqJ81Nj9M9dFpKeNgKLQgw+6BO2oXtU5uNUlZCwciI6E1ijsieCxku2C
# GxymyTtpcZBJoDYeRzzZUiFYr2Js/EA3Cgbge+QFkJexuqfdGqjgzHhJZz8OotKt
# 8cWz+ajsS6YYBXB/bHgnoPvS4qmmXvswoyuXJJFxvvxKDIS0qAE8EWsy5OTM46Nu
# 3B75JfUQvUHNeSJxco6uo5hM2zQfzB4C2hotkKff2kXk4lex5XCo6r6xXfgPp19I
# EoLSNLS++qU/kJbKB6YT71J5MQSrr+8tD3KQQ3/bJDZvph2WqGJ89dBjvVjfQo6I
# oUdPF3SYme401/A7PMeGxk+FqIjpUcovataQ5Ow17gYWTglmRSls2X3MDuUlVtp2
# /LNYmwRCrK/NwE1u1Tc99WYwggaQMIIEeKADAgECAhNzAAAAGstLMzDmmhRGAAAA
# AAAaMA0GCSqGSIb3DQEBDAUAMHMxEjAQBgoJkiaJk/IsZAEZFgJhdTETMBEGCgmS
# JomT8ixkARkWA2dvdjESMBAGCgmSJomT8ixkARkWAndhMRMwEQYKCZImiZPyLGQB
# GRYDZGh3MR8wHQYDVQQDExZDb21tdW5pdGllcy1Jc3N1aW5nLUNBMB4XDTE5MTIw
# NTA2NDUwMVoXDTI1MTIwMzA2NDUwMVowgZwxEjAQBgoJkiaJk/IsZAEZFgJhdTET
# MBEGCgmSJomT8ixkARkWA2dvdjESMBAGCgmSJomT8ixkARkWAndhMRMwEQYKCZIm
# iZPyLGQBGRYDZGh3MRQwEgYDVQQLEwtDb21tdW5pdGllczEZMBcGA1UECxMQU2Vy
# dmljZSBBY2NvdW50czEXMBUGA1UEAxMOU2NyaXB0IFNpZ25pbmcwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDbJdvNGj0fOE162+oVtZugVKx3eiLF7WQZ
# VbLesi1mqeiD8Wf8aXOMAzEqVmqgx+7k4OWA7eod8FQ+w4Q9qrVCx47gcjKpj5zS
# 5toAIrYkgBy9Ma0NFd5JyPrr4vosXmrll3VVU7/amO3rJy09n56SmBwRhDc+e8hc
# TiTRP1Jp344d5nItztA2GP8vJLwxr05tdO/hdbIlcPXegPH8cvlj4kLFlI8Lx+Wb
# 17znep3VJueIQz/WErb7PL0aH4Nz/Nq6jQBW4f3Ejz3W3yRk0Ou7wETi3ZEl6KMf
# q4Uk8vQ0Wr5466ItoaRMsDMnwdLyAyIoXn+b8g/y9PeDbVnrc87lAgMBAAGjggHx
# MIIB7TA9BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3FQiHxIdRgZG4R4KFjzKExK1/
# g7GYLA2BuaJ6gfumKAIBZAIBBDATBgNVHSUEDDAKBggrBgEFBQcDAzALBgNVHQ8E
# BAMCB4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUM2IT
# Vplt19WSgvabaPzKmD0/lS4wOAYDVR0RBDEwL6AtBgorBgEEAYI3FAIDoB8MHXNj
# cmlwdHNAY29tbXVuaXRpZXMud2EuZ292LmF1MB8GA1UdIwQYMBaAFELN9WyUMBDJ
# bpQ0ZiRTrPf7iLOCMFcGA1UdHwRQME4wTKBKoEiGRmh0dHA6Ly9wa2kuY29tbXVu
# aXRpZXMud2EuZ292LmF1L0NlcnRFbnJvbGwvQ29tbXVuaXRpZXMtSXNzdWluZy1D
# QS5jcmwwgZkGCCsGAQUFBwEBBIGMMIGJMFIGCCsGAQUFBzAChkZodHRwOi8vcGtp
# LmNvbW11bml0aWVzLndhLmdvdi5hdS9DZXJ0RW5yb2xsL0NvbW11bml0aWVzLUlz
# c3VpbmctQ0EuY3J0MDMGCCsGAQUFBzABhidodHRwOi8vY2VydHMuY29tbXVuaXRp
# ZXMud2EuZ292LmF1L29jc3AwDQYJKoZIhvcNAQEMBQADggIBAAvTD3kkVV3SMapx
# wWnR1enab2nFnChu1aEcpiupVBsEaejfnM+mYWyUMMh44hohVfnnW1qjSirxFWKN
# JRikAlie722v+3dlbAoNMNcIDjRpu8132ZsmDKM6gVipXlprsJ7EsyC7PZCnN5NK
# GbD358z0LaUG1tmb5USOzE5WaePdylacc5mrbCKxLhw0WFAxHndj9XHS4jawgeTT
# WdCPP3cNTuhY9NRxrsq/WnSMT4EBdlK73JvslsM8nk88QIk+HnD8NsJNwnBKs7VC
# tp0MKSIj3tk6w79wriHhz3QP4P3O7pfRs6h4laF+1cXTGgQdQH8aMtJE6k8Em68D
# hv7ct7IiW4RcO9QyAKnEYt3ovbd4f1TLIqF6g4odTp28EBXc3YMOPIXWwxxFD29b
# zdVYfQeI2lYoZX8Q4xENzX5d0m+rMRiJK5llvFR6r6tKFeiOpcovtOgA3qx/wYL0
# FKLtiCdvAuaLzfYLNcGEOHsjkyHesyTOcCHngT7iQzlZAsWv6590Sk+KtzOaTPZm
# fMj+CqecEDNJBqPlX9dkcFvL0JFF5nuennUU/rOgm+ylZSM57pjEakSWzrvz7u9o
# QgRS09e04kZiNMI7grWNm2fOA7wL+uYzjX8nrjJvIFyO4/+zXZwisu/imJdBLMK5
# 6uO60piavq3Bu4mQbu66jhht3/QwMIIGnjCCBIagAwIBAgITFQAAAAIS0EmVhlp3
# bgAAAAAAAjANBgkqhkiG9w0BAQwFADAeMRwwGgYDVQQDExNDb21tdW5pdGllcy1S
# b290LUNBMB4XDTE5MTExMzA3MDUyMFoXDTI5MTExMzA3MTUyMFowczESMBAGCgmS
# JomT8ixkARkWAmF1MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQB
# GRYCd2ExEzARBgoJkiaJk/IsZAEZFgNkaHcxHzAdBgNVBAMTFkNvbW11bml0aWVz
# LUlzc3VpbmctQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCX3+rd
# fTTCQ9vcJsYdEu499S6mZ3pYup3KYsxIwj8zEucp2E8S90KiTigK76WdlrZK4Xe7
# 1VFThMPC8UbLWmztDovVcNvWFNilyZJwiqzth93As9LYRcZjQYJPjxoV6KFKwEz0
# CDhXAzV+HnxTrHOchFCIrhJIPxzUOwynOXEJnpEh7Ks/5pkiLz6oAKI+ptiYxHW7
# WliWwqUKB8IPSPkf7EYzD/81hk5GvfgJEPLlcxTPPOwpXSVY9HYIAk5BCzKH6e+w
# 9u0NAdgdLlWt2XEoYnw71ka5KvObEpWkONcyZHuuRa5b2gZ9uf4cn4oKRAC7ei5k
# gJDWjpZIC/m9o3cj3XU3MNYw0ZUSVzuOJwjyKunMxdpIVT+qcpZ7/OoPs4IpCyms
# L5XW0D7OIr/ESQscBasiEIirL9j+vR8k4OKTMPEv9Dbe904itFeQvIeBA/CV4Cej
# Ij9/HuJfLiIeRqBLMp23g+HIOk4084e4//2LOdVA6btpFJp1qI7HznI8rDFRNVFy
# ZLE55KZREtfH6nbz2c6klWQRW2V087BioIXCcXWx7KdlnNwAt0cKHy2FA3m/RGX2
# rBMY5s6UirXNPjSXs2YNDHRlqoPmIeR6JorIsQbxUVKLRJ8dCRQ3PdSTaKumWsRC
# 94YrvXvp0pnEi2S0AJAA5lYXA5/M5NSUNEtwMQIDAQABo4IBfjCCAXowEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFELN9WyUMBDJbpQ0ZiRTrPf7iLOCMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MB8GA1UdIwQYMBaAFHG+SCYMwg95/ONpDg5CzWgbvGCqMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9wa2kuY29tbXVuaXRpZXMud2EuZ292LmF1L0NlcnRFbnJv
# bGwvQ29tbXVuaXRpZXMtUm9vdC1DQS5jcmwwgZYGCCsGAQUFBwEBBIGJMIGGME8G
# CCsGAQUFBzAChkNodHRwOi8vcGtpLmNvbW11bml0aWVzLndhLmdvdi5hdS9DZXJ0
# RW5yb2xsL0NvbW11bml0aWVzLVJvb3QtQ0EuY3J0MDMGCCsGAQUFBzABhidodHRw
# Oi8vY2VydHMuY29tbXVuaXRpZXMud2EuZ292LmF1L29jc3AwDQYJKoZIhvcNAQEM
# BQADggIBAD17IKXvnlOllGI8P+6o3rCqgzIw9x/K58KaLOUB+ZmEjVt2wk9WQRZ/
# FTEGF6azkRuTy9zoWJIi+yu8n2TJc11aLycaR7ECc7aPKDEs0fmvr+nNLAcswXwq
# vkGPsJugcD02Hq99c36EgPFMcYMwAei7u51nsxIXrxanJUexzDs05YiAg4u8PrlK
# 7Cuym+kceRU82L06rWsTVIVMO02csfJ3Qz5bsT6UIxCmZeE5NjTERwNmvHe84kVU
# jGDm1AtIJoBeaIYGGIR/3COMjql7KfdAJcIrKYv6BOoo0K+duKYi4LuSao77kg+9
# wEezIgOWg32HgPfUDIbuTZXZfQhToKN7T/omAmg+HFT8Fmq8Qbt9ETvYXnLF0szp
# 8wN5thl0UK12A/SgUS1Og3M9WWKKcFEPStjGJ0aG8la79hE3rARhKlhJSw/abLvl
# rPb/UvYJUxExR8V2KjiAMxyqQt5gLW99zG1q0N+itxiV3bbHPbVZIV/ml5wSeu0Y
# FcSAE8EX478JxWuaNlOTcdliJGEuFt5hkrTWdfShsubvr9IvHy3cx6BZSt0bl/+e
# XkrtyT2VugqTd0DUG8JwQ3YiiFMP5L/mHSt8nPuIBtehc17kkGqw6rnvSZYG2X4h
# ZZjIg8xlwwBxgMTDqiYjPpwjx5ertA4UEH2UXyN4HNiXDetibAKOMYICLDCCAigC
# AQEwgYowczESMBAGCgmSJomT8ixkARkWAmF1MRMwEQYKCZImiZPyLGQBGRYDZ292
# MRIwEAYKCZImiZPyLGQBGRYCd2ExEzARBgoJkiaJk/IsZAEZFgNkaHcxHzAdBgNV
# BAMTFkNvbW11bml0aWVzLUlzc3VpbmctQ0ECE3MAAAAay0szMOaaFEYAAAAAABow
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFJHOat1P/OCEgvHk9gHkFHKziJgBMA0GCSqGSIb3DQEB
# AQUABIIBAEq0VjjaLYyLdENKWl2AVrPkqU7/bLt8ydHCFjxZ4FRLc8V1HTGGE+3j
# DC3sBksKP+tb9+3ZfNwwthXXUpwt0U6YrpYEPxhMolQyAdNzX8d4kn6n3ASR1fD4
# 61cEgw7+i4P08J+iL/hnSRoBk43VdXUg3HxIhA/zALfy2KiY36DcyaYxb0cHtg9K
# UflFnAN02KSRKLuoavLlXEzrvBHUcwLQOJG4j0+r7/nSdhE3JtLfo+lTet4jIF9B
# sHoEzG5gMWr074AZ2uJnadqFNTWVUmAp5AOTKzGDrOlyfq/eNe/xYdu5k8r6nCSZ
# zzx2WqE0DQU9NykYhSS66JkrH7wtcGs=
# SIG # End signature block
