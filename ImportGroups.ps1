Import-Module ActiveDirectory

$SourceSAM = Read-host = "Please enter the source SAMAccountName"
$DestSAM = Read-host "Please enter the destination SAMAccountName"
$ExportFile = Get-ChildItem -Path '\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Exports' -Filter *$SourceSAM* | Where-Object {$_.Name -like '*.csv'} | Select-Object -ExpandProperty Name

$GroupImport = Import-CSV "\\dhw.wa.gov.au\CorporateData\IS\TSS\Support Centre\EntOps\Scripts\Exports\$ExportFile"
    $GroupImport = $GroupImport | Where-Object {$_.Name -ne 'Domain Users'}    
    $GroupImport | ForEach-Object {
        Add-ADPrincipalGroupMembership -Identity $DestSAM -MemberOf $_.name -verbose
    }