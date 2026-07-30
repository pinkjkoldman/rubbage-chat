param(
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$deployRoot = Join-Path $projectRoot 'deploy'
$outputRoot = Join-Path $projectRoot 'dist\server'
$archive = Join-Path $projectRoot 'dist\RubbageChatServer-2.5.0-beta.1.zip'

if (-not $SkipBuild) {
    & (Join-Path $projectRoot 'Build-RubbageChat.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Base build failed.'
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $deployRoot 'RubbageChatServer.exe'))) {
    throw 'Server build artifact is missing.'
}

$resolvedOutput = [IO.Path]::GetFullPath($outputRoot)
$resolvedDist = [IO.Path]::GetFullPath((Join-Path $projectRoot 'dist'))
if (-not $resolvedOutput.StartsWith($resolvedDist,
    [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to replace unexpected path: $resolvedOutput"
}
if (Test-Path -LiteralPath $outputRoot) {
    Remove-Item -LiteralPath $outputRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

Get-ChildItem -LiteralPath $deployRoot -Force |
    Where-Object {
        $_.Name -notin @(
            'RubbageChat.exe',
            'RubbageChatProtocolSmokeTest.exe',
            'data'
        )
    } |
    Copy-Item -Destination $outputRoot -Recurse -Force
Copy-Item -LiteralPath (
    Join-Path $projectRoot 'rubbagechat.server.public-test.ini.example') `
    -Destination (Join-Path $outputRoot 'rubbagechat.ini') -Force
Copy-Item -LiteralPath (
    Join-Path $projectRoot 'deployment\Start-ProductionServer.ps1') `
    -Destination $outputRoot -Force
Copy-Item -LiteralPath (
    Join-Path $projectRoot 'DEPLOYMENT_BLUEPRINT.md') `
    -Destination $outputRoot -Force

if (Test-Path -LiteralPath $archive) {
    Remove-Item -LiteralPath $archive -Force
}
Compress-Archive -Path (Join-Path $outputRoot '*') `
    -DestinationPath $archive -CompressionLevel Optimal
Get-Item -LiteralPath $archive
