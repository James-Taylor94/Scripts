

$LastDirSyncTime = (Get-MsolCompanyInformation).LastDirSyncTime
$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName
$currentTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
$LocalLastDirSyncTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($LastDirSyncTime, $currentTimeZone)

write-host Last AAD sync: $LocalLastDirSyncTime