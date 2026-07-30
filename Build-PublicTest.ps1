param(
    [Parameter(Mandatory = $true)]
    [string]$ServerHost,
    [string]$BootstrapUrl,
    [string]$ServerCertificateFile = 'C:/ProgramData/RubbageChat/tls/fullchain.pem',
    [string]$ServerPrivateKeyFile = 'C:/ProgramData/RubbageChat/tls/privkey.pem',
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

if (([Uri]::CheckHostName($ServerHost) -ne [UriHostNameType]::Dns) -or
    ($ServerHost -notmatch '\.')) {
    throw 'ServerHost must be a DNS name covered by the TLS certificate.'
}
if (-not $BootstrapUrl) {
    $BootstrapUrl = "https://$ServerHost/.well-known/rubbagechat/client"
}
$bootstrapUri = [Uri]$BootstrapUrl
if (-not $bootstrapUri.IsAbsoluteUri -or $bootstrapUri.Scheme -ne 'https') {
    throw 'BootstrapUrl must be an absolute HTTPS URL.'
}

$projectRoot = $PSScriptRoot
$deployRoot = Join-Path $projectRoot 'deploy'
$outputRoot = Join-Path $projectRoot 'dist\public-test'
$clientRoot = Join-Path $outputRoot 'client'
$serverRoot = Join-Path $outputRoot 'server'

if (-not $SkipBuild) {
    & (Join-Path $projectRoot 'Build-RubbageChat.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Base build failed.'
    }
}
if ((-not (Test-Path -LiteralPath (Join-Path $deployRoot 'RubbageChat.exe'))) -or
    (-not (Test-Path -LiteralPath (Join-Path $deployRoot 'RubbageChatServer.exe')))) {
    throw 'Build artifacts are missing. Run Build-RubbageChat.ps1 first.'
}
$requiredTlsRuntime = @(
    (Join-Path $deployRoot 'tls\qopensslbackend.dll'),
    (Join-Path $deployRoot 'libssl-3-x64.dll'),
    (Join-Path $deployRoot 'libcrypto-3-x64.dll')
)
foreach ($runtimeFile in $requiredTlsRuntime) {
    if (-not (Test-Path -LiteralPath $runtimeFile)) {
        throw 'OpenSSL runtime is missing. Set RUBBAGECHAT_OPENSSL_ROOT and rebuild.'
    }
}

foreach ($target in @($clientRoot, $serverRoot)) {
    $resolvedOutput = [IO.Path]::GetFullPath($target)
    $resolvedExpectedRoot = [IO.Path]::GetFullPath($outputRoot)
    if (-not $resolvedOutput.StartsWith($resolvedExpectedRoot,
        [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to replace unexpected path: $resolvedOutput"
    }
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Copy-Item -Path (Join-Path $deployRoot '*') -Destination $target -Recurse -Force
    $runtimeData = Join-Path $target 'data'
    if (Test-Path -LiteralPath $runtimeData) {
        Remove-Item -LiteralPath $runtimeData -Recurse -Force
    }
    Get-ChildItem -LiteralPath $target -Recurse -File |
        Where-Object { $_.Extension -in @('.pem', '.key', '.pfx', '.p12') } |
        Remove-Item -Force
}

foreach ($file in @('RubbageChatServer.exe', 'RubbageChatProtocolSmokeTest.exe')) {
    $path = Join-Path $clientRoot $file
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
    }
}
foreach ($file in @('RubbageChat.exe', 'RubbageChatProtocolSmokeTest.exe')) {
    $path = Join-Path $serverRoot $file
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
    }
}

$clientConfiguration = Get-Content -Raw -Encoding utf8 -LiteralPath (
    Join-Path $projectRoot 'rubbagechat.client.public-test.ini.example')
$clientConfiguration = $clientConfiguration.Replace('chat.example.com', $ServerHost)
$clientConfiguration = $clientConfiguration.Replace(
    'https://config.example.com/v1/bootstrap', $BootstrapUrl)
Set-Content -Encoding utf8 -LiteralPath (
    Join-Path $clientRoot 'rubbagechat.ini') -Value $clientConfiguration

$serverConfiguration = Get-Content -Raw -Encoding utf8 -LiteralPath (
    Join-Path $projectRoot 'rubbagechat.server.public-test.ini.example')
$serverConfiguration = $serverConfiguration.Replace(
    'C:/ProgramData/RubbageChat/tls/fullchain.pem', $ServerCertificateFile).Replace(
    'C:/ProgramData/RubbageChat/tls/privkey.pem', $ServerPrivateKeyFile)
Set-Content -Encoding utf8 -LiteralPath (
    Join-Path $serverRoot 'rubbagechat.ini') -Value $serverConfiguration

$bootstrapDocument = @{
    schemaVersion = 1
    expiresAt = (Get-Date).ToUniversalTime().AddDays(6).ToString('o')
    endpoints = @(
        @{
            transport = 'tls-tcp'
            host = $ServerHost
            port = 443
            priority = 10
        }
    )
} | ConvertTo-Json -Depth 4
Set-Content -Encoding utf8 -LiteralPath (
    Join-Path $outputRoot 'bootstrap.json') -Value $bootstrapDocument

Copy-Item -LiteralPath (Join-Path $projectRoot 'PUBLIC_TEST_DEPLOYMENT.md') `
    -Destination (Join-Path $outputRoot 'README.md') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'DEPLOYMENT_BLUEPRINT.md') `
    -Destination $outputRoot -Force

Write-Host "Public test packages created: $outputRoot"
Write-Warning 'Set RUBBAGECHAT_MONGO_URI on the server before launch; never ship it in the client package.'
