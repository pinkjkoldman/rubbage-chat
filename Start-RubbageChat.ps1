$ErrorActionPreference = 'Stop'

$deployDirectory = if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'RubbageChat.exe')) {
    $PSScriptRoot
}
else {
    Join-Path $PSScriptRoot 'deploy'
}
$serverExecutable = Join-Path $deployDirectory 'RubbageChatServer.exe'
$clientExecutable = Join-Path $deployDirectory 'RubbageChat.exe'

function Start-RubbageChatProcess(
    [string]$filePath,
    [string]$workingDirectory,
    [bool]$hidden
) {
    $processInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $processInfo.FileName = $filePath
    $processInfo.WorkingDirectory = $workingDirectory
    $processInfo.UseShellExecute = $true
    if ($hidden) {
        $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    }
    [System.Diagnostics.Process]::Start($processInfo) | Out-Null
}

function Test-LocalTcpPort([int]$port) {
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $connect = $client.ConnectAsync('127.0.0.1', $port)
        return $connect.Wait(800) -and $client.Connected
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

function Start-LocalMongoDb {
    if (Test-LocalTcpPort 27017) {
        return
    }

    $candidates = @()
    if ($env:RUBBAGECHAT_MONGOD_PATH) {
        $candidates += $env:RUBBAGECHAT_MONGOD_PATH
    }
    $command = Get-Command mongod.exe -ErrorAction SilentlyContinue
    if ($command) {
        $candidates += $command.Source
    }
    $candidates += 'D:\mongodb\mongodb-windows-x86_64-8.0.6\mongodb-win32-x86_64-windows-8.0.6\bin\mongod.exe'
    $mongod = $candidates |
        Where-Object { $_ -and (Test-Path -LiteralPath $_) } |
        Select-Object -First 1
    if (-not $mongod) {
        throw 'Local server requires MongoDB 8.x or RUBBAGECHAT_MONGOD_PATH.'
    }

    $mongoData = if ($env:RUBBAGECHAT_MONGO_DATA) {
        $env:RUBBAGECHAT_MONGO_DATA
    }
    else {
        Join-Path $env:LOCALAPPDATA 'RubbageChat\mongodb'
    }
    $mongoLog = Join-Path $mongoData 'mongod.log'
    New-Item -ItemType Directory -Path $mongoData -Force | Out-Null

    $processInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $processInfo.FileName = $mongod
    $processInfo.WorkingDirectory = Split-Path -Parent $mongod
    $processInfo.Arguments = "--dbpath `"$mongoData`" --logpath `"$mongoLog`" " +
        '--bind_ip 127.0.0.1 --port 27017'
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $processInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    [System.Diagnostics.Process]::Start($processInfo) | Out-Null

    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        if (Test-LocalTcpPort 27017) {
            return
        }
        Start-Sleep -Milliseconds 250
    }
    throw "MongoDB did not start. Log: $mongoLog"
}

if (-not (Test-Path -LiteralPath $serverExecutable)) {
    throw "Server executable not found: $serverExecutable"
}
if (-not (Test-Path -LiteralPath $clientExecutable)) {
    throw "Client executable not found: $clientExecutable"
}

$configurationPath = Join-Path $deployDirectory 'rubbagechat.ini'
$configuredHost = '127.0.0.1'
if (Test-Path -LiteralPath $configurationPath) {
    $hostLine = Get-Content -LiteralPath $configurationPath |
        Where-Object { $_ -match '^\s*host\s*=' } |
        Select-Object -First 1
    if ($hostLine) {
        $configuredHost = ($hostLine -split '=', 2)[1].Trim()
    }
}

if ($configuredHost -in @('127.0.0.1', 'localhost', '::1')) {
    Start-LocalMongoDb
    $serverAlreadyRunning = Get-Process -Name 'RubbageChatServer' -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $serverExecutable }

    if (-not $serverAlreadyRunning) {
        Start-RubbageChatProcess $serverExecutable $deployDirectory $true
    }
    for ($attempt = 0; $attempt -lt 20; $attempt++) {
        if (Test-LocalTcpPort 7502) {
            break
        }
        Start-Sleep -Milliseconds 250
    }
    if (-not (Test-LocalTcpPort 7502)) {
        throw 'RubbageChatServer did not listen on port 7502. Run it in a terminal for details.'
    }
}

Start-RubbageChatProcess $clientExecutable $deployDirectory $false
