$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$etlDir = Split-Path -Parent $scriptDir
$envFile = Join-Path $etlDir ".env.local"

if (-not (Test-Path $envFile)) {
  $defaultServer = if ([string]::IsNullOrWhiteSpace($env:COMPUTERNAME)) { "YOUR_SQL_SERVER" } else { $env:COMPUTERNAME }
  $defaultEnv = @(
    "BOOKSTORE_SQL_SERVER=$defaultServer"
    "BOOKSTORE_DW_DB=Bookstore_DW"
    "BOOKSTORE_OLTP_DB=Bookstore_OLTP"
  ) -join [Environment]::NewLine

  Set-Content -Path $envFile -Value $defaultEnv -Encoding UTF8
  Write-Host "Created $envFile with default values. Update it if your SQL instance differs."
}

# Parse KEY=VALUE lines from .env.local
$vars = @{}
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -eq "" -or $line.StartsWith("#")) { return }

    $parts = $line -split "=", 2
    if ($parts.Count -ne 2) { return }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")
    $vars[$key] = $value
}

$server = $vars["BOOKSTORE_SQL_SERVER"]
$dwDb = $vars["BOOKSTORE_DW_DB"]
$oltpDb = $vars["BOOKSTORE_OLTP_DB"]

if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($dwDb) -or [string]::IsNullOrWhiteSpace($oltpDb)) {
    throw "BOOKSTORE_SQL_SERVER, BOOKSTORE_DW_DB, and BOOKSTORE_OLTP_DB are required in .env.local"
}

$cmDwPath = Join-Path $etlDir "cmDW.conmgr"
$cmOltpPath = Join-Path $etlDir "cmOLTP.conmgr"

$dwContent = @"
<?xml version="1.0"?>
<DTS:ConnectionManager xmlns:DTS="www.microsoft.com/SqlServer/Dts"
  DTS:ObjectName="Bookstore_DW"
  DTS:DTSID="{61384584-DB61-469B-A6E9-DC2D2FF6A084}"
  DTS:CreationName="OLEDB">
  <DTS:ObjectData>
    <DTS:ConnectionManager
      DTS:ConnectRetryCount="1"
      DTS:ConnectRetryInterval="5"
      DTS:ConnectionString="Data Source=$server;Initial Catalog=$dwDb;Provider=SQLNCLI11.1;Integrated Security=SSPI;Application Name=SSIS-Bookstore_ETL-{61384584-DB61-469B-A6E9-DC2D2FF6A084}Bookstore_DW;Auto Translate=False;" />
  </DTS:ObjectData>
</DTS:ConnectionManager>
"@

$oltpContent = @"
<?xml version="1.0"?>
<DTS:ConnectionManager xmlns:DTS="www.microsoft.com/SqlServer/Dts"
  DTS:ObjectName="Bookstore_OLTP"
  DTS:DTSID="{57C269E3-4DD7-4032-A3FC-C87B62EA6030}"
  DTS:CreationName="OLEDB">
  <DTS:ObjectData>
    <DTS:ConnectionManager
      DTS:ConnectRetryCount="1"
      DTS:ConnectRetryInterval="5"
      DTS:ConnectionString="Data Source=$server;Initial Catalog=$oltpDb;Provider=SQLNCLI11.1;Integrated Security=SSPI;Application Name=SSIS-Bookstore_ETL-{57C269E3-4DD7-4032-A3FC-C87B62EA6030}Bookstore_OLTP;Auto Translate=False;" />
  </DTS:ObjectData>
</DTS:ConnectionManager>
"@

Set-Content -Path $cmDwPath -Value $dwContent -Encoding UTF8
Set-Content -Path $cmOltpPath -Value $oltpContent -Encoding UTF8

Write-Host "Generated local connection managers:"
Write-Host " - $cmDwPath"
Write-Host " - $cmOltpPath"
