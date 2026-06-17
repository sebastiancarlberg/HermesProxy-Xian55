# HermesProxy-Xian55 local build script.
# Publishes the current branch into this repo's local build folder for WotLK testing.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Start-Transcript -Path (Join-Path $root "setup.log") -Force | Out-Null

try {
    $buildDir = Join-Path $root "build"
    $csproj = Join-Path $root "HermesProxy\HermesProxy.csproj"

    function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }

    if (-not (Test-Path $csproj)) { throw "Source not found: $csproj" }

    Step "Locating a dotnet SDK that can build net10.0"
    $dotnetExe = $null
    $candidates = @(
        "$env:USERPROFILE\.dotnet-hermes-net10\dotnet.exe",
        "$env:USERPROFILE\.dotnet\dotnet.exe",
        "$env:ProgramFiles\dotnet\dotnet.exe",
        "$env:USERPROFILE\.dotnet-codex-sdk\dotnet.exe"
    )
    $onPath = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($onPath) { $candidates += $onPath.Source }
    foreach ($cand in ($candidates | Select-Object -Unique)) {
        if (-not (Test-Path $cand)) { continue }
        $sdks = & $cand --list-sdks 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $sdks) {
            Write-Host "    $cand has no SDK - skipping"
            continue
        }
        $hasNet10 = $false
        foreach ($sdk in $sdks) {
            if ($sdk -match '^(10|1[1-9])\.') { $hasNet10 = $true; break }
        }
        if ($hasNet10) {
            $dotnetExe = $cand
            Write-Host "    Using $cand"
            break
        }
        Write-Host "    $cand SDKs do not support net10.0 - skipping"
    }
    if (-not $dotnetExe) {
        throw "No .NET 10+ SDK found. Install one, or place it at $env:USERPROFILE\.dotnet-hermes-net10\dotnet.exe."
    }

    $env:DOTNET_ROOT = Split-Path -Parent $dotnetExe
    $env:PATH = $env:DOTNET_ROOT + ";" + $env:PATH

    Step "Publishing Xian55 WotLK build to $buildDir"
    & $dotnetExe publish $csproj -c Release -r win-x64 --self-contained true -p:UsePublishBuildSettings=true -p:DebugType=None -p:DebugSymbols=false -o $buildDir
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed with exit code $LASTEXITCODE" }
    if (-not (Test-Path (Join-Path $buildDir "HermesProxy.exe"))) { throw "Build finished but HermesProxy.exe missing in $buildDir" }

    Step "Writing local WotLK appsettings.json"
    $settings = @'
{
  "ClientOptions": {
    "ClientBuild": "V3_4_3_54261",
    "SeedHex": "91D59BB7D4E183A5222B5F38F4B886FF",
    "ReportedOS": "OSX",
    "ReportedPlatform": "x86"
  },
  "LegacyServerOptions": {
    "Build": "V3_3_5a_12340",
    "Address": "127.0.0.1",
    "Port": 3724
  },
  "ProxyNetworkOptions": {
    "ExternalAddress": "127.0.0.1",
    "RestPort": 8081,
    "BNetPort": 1119,
    "RealmPort": 8084,
    "InstancePort": 8086
  },
  "LoggingOptions": {
    "MinimumLevel": "Information",
    "ServerLevel": "Information",
    "NetworkLevel": "Information",
    "StorageLevel": "Information",
    "PacketLevel": "Warning",
    "ConsoleLevel": "Information",
    "ToFile": true,
    "Directory": "Logs"
  },
  "DiagnosticsOptions": {
    "PacketsLog": true,
    "EnableMetrics": false,
    "EnableVersionCheck": false
  }
}
'@
    Set-Content -LiteralPath (Join-Path $buildDir "appsettings.json") -Value $settings -Encoding ASCII

    Step "Done"
    Write-Host ""
    Write-Host "Xian55 build: $buildDir\HermesProxy.exe" -ForegroundColor Green
    Write-Host "Launch with: $root\launchers\Start Hermes Xian55 + Client.cmd"
} catch {
    Write-Host ""
    Write-Host "SETUP FAILED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Full log: $root\setup.log"
    exit 1
} finally {
    Stop-Transcript | Out-Null
}
