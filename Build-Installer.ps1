$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$installerRoot = Join-Path $projectRoot 'installer'
$buildRoot = Join-Path $installerRoot 'build'
$payloadRoot = Join-Path $buildRoot 'payload'
$packageRoot = Join-Path $buildRoot 'package'
$distributionRoot = Join-Path $projectRoot 'dist'
$deployRoot = Join-Path $projectRoot 'deploy'
$sevenZipRoot = 'C:\Program Files\7-Zip'
$sevenZip = Join-Path $sevenZipRoot '7z.exe'
$iexpress = Join-Path $env:SystemRoot 'System32\iexpress.exe'
$setupPath = Join-Path $distributionRoot 'RubbageChatSetup.exe'

foreach ($required in @(
    (Join-Path $deployRoot 'RubbageChat.exe'),
    (Join-Path $deployRoot 'RubbageChatServer.exe'),
    $sevenZip,
    $iexpress
)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Missing installer dependency: $required"
    }
}

foreach ($generatedDirectory in @($buildRoot, $distributionRoot)) {
    $resolved = [System.IO.Path]::GetFullPath($generatedDirectory)
    if (-not $resolved.StartsWith(
        [System.IO.Path]::GetFullPath($projectRoot) + '\',
        [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Generated directory is outside the project: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
    New-Item -ItemType Directory -Path $resolved -Force | Out-Null
}

New-Item -ItemType Directory -Path $payloadRoot, $packageRoot -Force | Out-Null

$excludedNames = @(
    'RubbageChatProtocolSmokeTest.exe',
    'Qt6Widgets.dll',
    'Qt6Quick3DUtils.dll',
    'qmltooling',
    'user_1.sqlite',
    'user_1.sqlite-shm',
    'user_1.sqlite-wal',
    'rubbagechat.sqlite-shm',
    'rubbagechat.sqlite-wal'
)
Get-ChildItem -LiteralPath $deployRoot -Force |
    Where-Object { $excludedNames -notcontains $_.Name } |
    Copy-Item -Destination $payloadRoot -Recurse -Force

Copy-Item -LiteralPath (Join-Path $projectRoot 'Start-RubbageChat.ps1') `
    -Destination $payloadRoot -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'Stop-RubbageChat.ps1') `
    -Destination $payloadRoot -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'Uninstall-RubbageChat.ps1') `
    -Destination $payloadRoot -Force

$archivePath = Join-Path $packageRoot 'RubbageChatPayload.7z'
& $sevenZip a -t7z -mx=7 $archivePath (Join-Path $payloadRoot '*') | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to create the installer payload'
}

Copy-Item -LiteralPath $sevenZip -Destination $packageRoot -Force
Copy-Item -LiteralPath (Join-Path $sevenZipRoot '7z.dll') -Destination $packageRoot -Force
Copy-Item -LiteralPath (Join-Path $installerRoot 'package\install.cmd') `
    -Destination $packageRoot -Force
Copy-Item -LiteralPath (Join-Path $installerRoot 'package\install.ps1') `
    -Destination $packageRoot -Force

$sedPath = Join-Path $buildRoot 'RubbageChatSetup.sed'
$sed = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$setupPath
FriendlyName=RubbageChat Setup
AppLaunched=install.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=install.cmd
UserQuietInstCmd=install.cmd
SourceFiles=SourceFiles
[Strings]
FILE0=install.cmd
FILE1=install.ps1
FILE2=RubbageChatPayload.7z
FILE3=7z.exe
FILE4=7z.dll
[SourceFiles]
SourceFiles0=$packageRoot\
[SourceFiles0]
%FILE0%=
%FILE1%=
%FILE2%=
%FILE3%=
%FILE4%=
"@
$sed | Set-Content -LiteralPath $sedPath -Encoding ascii

& $iexpress /N /Q $sedPath
$iexpressExitCode = $LASTEXITCODE
$archiveSize = (Get-Item -LiteralPath $archivePath).Length
for ($attempt = 0; $attempt -lt 240; $attempt++) {
    if ((Test-Path -LiteralPath $setupPath) -and
        (Get-Item -LiteralPath $setupPath).Length -gt $archiveSize) {
        break
    }
    Start-Sleep -Milliseconds 500
}
if (-not (Test-Path -LiteralPath $setupPath) -or
    (Get-Item -LiteralPath $setupPath).Length -le $archiveSize) {
    throw 'IExpress did not create the installer'
}
if ($iexpressExitCode -ne 0) {
    Write-Warning "IExpress returned $iexpressExitCode, but the installer was created."
}

Get-Item -LiteralPath $setupPath
