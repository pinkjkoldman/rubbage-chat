$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$qtRoot = 'D:\Qt\6.11.0\mingw_64'
$toolchainRoot = 'D:\Qt\Tools\mingw1310_64'
$qmake = Join-Path $qtRoot 'bin\qmake.exe'
$make = Join-Path $toolchainRoot 'bin\mingw32-make.exe'
$windeployqt = Join-Path $qtRoot 'bin\windeployqt.exe'
$buildRoot = Join-Path $projectRoot 'qmake-build'
$deployRoot = Join-Path $projectRoot 'deploy'

foreach ($tool in @($qmake, $make, $windeployqt)) {
    if (-not (Test-Path -LiteralPath $tool)) {
        throw "Missing Qt build tool: $tool"
    }
}

$env:PATH = (Join-Path $toolchainRoot 'bin') + ';' +
    (Join-Path $qtRoot 'bin') + ';' + $env:PATH

$opensslCandidates = @()
if ($env:RUBBAGECHAT_OPENSSL_ROOT) {
    $opensslCandidates += $env:RUBBAGECHAT_OPENSSL_ROOT
}
$opensslCandidates += 'C:\Program Files\Git\mingw64'
$opensslRoot = $opensslCandidates |
    Where-Object {
        Test-Path -LiteralPath (Join-Path $_ 'bin\libssl-3-x64.dll')
    } |
    Select-Object -First 1

$targets = @(
    @{
        Name = 'client'
        Project = Join-Path $projectRoot 'apps\client\RubbageChatClient.pro'
    },
    @{
        Name = 'server'
        Project = Join-Path $projectRoot 'apps\server\RubbageChatServer.pro'
    },
    @{
        Name = 'tests'
        Project = Join-Path $projectRoot 'tests\protocol\ProtocolSmokeTest.pro'
    }
)

foreach ($target in $targets) {
    $outputDirectory = Join-Path $buildRoot $target.Name
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    & $qmake $target.Project -o (Join-Path $outputDirectory 'Makefile')
    if ($LASTEXITCODE -ne 0) {
        throw "qmake configuration failed: $($target.Name)"
    }
    & $make -C $outputDirectory -j4
    if ($LASTEXITCODE -ne 0) {
        throw "qmake build failed: $($target.Name)"
    }
}

New-Item -ItemType Directory -Path $deployRoot -Force | Out-Null
$staleArtifacts = @(
    (Join-Path $deployRoot 'user_1.sqlite'),
    (Join-Path $deployRoot 'user_1.sqlite-shm'),
    (Join-Path $deployRoot 'user_1.sqlite-wal'),
    (Join-Path $deployRoot 'rubbagechat.sqlite'),
    (Join-Path $deployRoot 'rubbagechat.sqlite-shm'),
    (Join-Path $deployRoot 'rubbagechat.sqlite-wal'),
    (Join-Path $deployRoot 'sqldrivers')
)
foreach ($staleArtifact in $staleArtifacts) {
    if (Test-Path -LiteralPath $staleArtifact) {
        Remove-Item -LiteralPath $staleArtifact -Recurse -Force
    }
}
$configurationTemplate = Join-Path $projectRoot 'rubbagechat.ini.example'
$configurationTarget = Join-Path $deployRoot 'rubbagechat.ini'
if (-not (Test-Path -LiteralPath $configurationTarget)) {
    Copy-Item -LiteralPath $configurationTemplate -Destination $configurationTarget
}
$deployExecutables = @{
    (Join-Path $buildRoot 'client\RubbageChat.exe') = 'RubbageChat.exe'
    (Join-Path $buildRoot 'server\RubbageChatServer.exe') = 'RubbageChatServer.exe'
    (Join-Path $buildRoot 'tests\RubbageChatProtocolSmokeTest.exe') =
        'RubbageChatProtocolSmokeTest.exe'
}

foreach ($source in $deployExecutables.Keys) {
    Copy-Item -LiteralPath $source -Destination (Join-Path $deployRoot $deployExecutables[$source]) -Force
}

$deploymentArguments = @(
    '--qmldir', (Join-Path $projectRoot 'apps\client\ui'),
    '--compiler-runtime',
    '--no-translations'
)
if ($opensslRoot) {
    $deploymentArguments += @(
        '--openssl-root', $opensslRoot
    )
}
& $windeployqt @deploymentArguments (Join-Path $deployRoot 'RubbageChat.exe')
if ($LASTEXITCODE -ne 0) {
    throw 'windeployqt deployment failed'
}

Write-Host "qmake build and deployment completed: $deployRoot"
