Import-Module ActiveDirectory

$SourceSAM = Read-host "Please enter the source SAMAccountName"
$DestSAM = Read-host "Please enter the destination SAMAccountName"
$ExportFile = Get-ChildItem -Path 'C:\temp\Imports' -Filter *$SourceSAM* | Where-Object {$_.Name -like '*.csv'} | Select-Object -ExpandProperty Name

$GroupImport = Import-CSV "\\dhw.wa.gov.au\corporatedata\IS\TSS\Support Centre\EntOps\Scripts\Exports\$ExportFile"
    $GroupImport = $GroupImport | Where-Object {$_.Name -ne 'Domain Users'}    
    $GroupImport | ForEach-Object {
        $Name = $_.Name
        Add-ADPrincipalGroupMembership -Identity $DestSAM -MemberOf $_.ObjectGUID
        Write-Host "Added $Name to $DestSAM"
    }