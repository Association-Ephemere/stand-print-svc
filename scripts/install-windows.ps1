#Requires -RunAsAdministrator
param(
    [string]$InstallDir = "C:\PrintSvc",
    [string]$BrokerHost = "localhost",
    [int]$BrokerPort = 5672,
    [string]$StorageEndpoint = "localhost:9000",
    [string]$StorageBucket = "photostand",
    [string]$PrinterName = "",
    [double]$PaperWidthInches = 6.0,
    [double]$PaperHeightInches = 4.0,
    [switch]$ForceConfig
)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ServiceName = "PrintSvc"

Write-Host "Stopping existing $ServiceName service (if running)..."
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "Publishing PrintSvc (win-x64 self-contained) to $InstallDir..."
dotnet publish (Join-Path $RepoRoot "src\PrintSvc\PrintSvc.csproj") `
    -c Release -r win-x64 --self-contained true -o $InstallDir

$LocalConfigPath = Join-Path $InstallDir "appsettings.local.json"
if ($ForceConfig -or -not (Test-Path $LocalConfigPath)) {
    Write-Host "Writing $LocalConfigPath..."
    @{
        Broker = @{
            Host = $BrokerHost
            Port = $BrokerPort
            Username = "guest"
            Password = "guest"
            JobsQueue = "print.jobs"
            ResultsQueue = "print.status"
        }
        Storage = @{
            Endpoint = $StorageEndpoint
            AccessKey = "minioadmin"
            SecretKey = "minioadmin"
            Bucket = $StorageBucket
            TempDirectory = "./tmp/"
            UseSSL = $false
        }
        Printing = @{
            PrinterName = $PrinterName
            PaperWidthInches = $PaperWidthInches
            PaperHeightInches = $PaperHeightInches
        }
    } | ConvertTo-Json -Depth 4 | Set-Content -Path $LocalConfigPath -Encoding UTF8
}

$ExePath = Join-Path $InstallDir "PrintSvc.exe"
if (-not (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating Windows service $ServiceName..."
    sc.exe create $ServiceName binPath= "`"$ExePath`"" start= auto | Out-Null
    sc.exe failure $ServiceName reset= 86400 actions= restart/5000/restart/10000/restart/30000 | Out-Null
} else {
    sc.exe config $ServiceName binPath= "`"$ExePath`"" start= auto | Out-Null
}

Write-Host "Starting $ServiceName..."
Start-Service -Name $ServiceName
Get-Service -Name $ServiceName
