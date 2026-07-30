$ErrorActionPreference = 'SilentlyContinue'

$installDirectory = [System.IO.Path]::GetFullPath($PSScriptRoot)
$expectedDirectory = [System.IO.Path]::GetFullPath(
    (Join-Path $env:LOCALAPPDATA 'Programs\RubbageChat'))
if ($installDirectory -ne $expectedDirectory) {
    throw "Refusing to uninstall a non-standard directory: $installDirectory"
}

$installedExecutables = @(
    (Join-Path $installDirectory 'RubbageChat.exe'),
    (Join-Path $installDirectory 'RubbageChatServer.exe')
)
Get-Process RubbageChat, RubbageChatServer -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $installedExecutables -contains $_.Path } |
    Stop-Process -Force

$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'RubbageChat.lnk'
$startMenuDirectory = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\RubbageChat'
Remove-Item -LiteralPath $desktopShortcut -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $startMenuDirectory -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\RubbageChat' `
    -Recurse -Force -ErrorAction SilentlyContinue

$cleanupScript = Join-Path $env:TEMP "rubbagechat-uninstall-$PID.cmd"
@(
    '@echo off',
    'timeout /t 2 /nobreak >nul',
    ('rmdir /s /q "{0}"' -f $installDirectory),
    'del /q "%~f0"'
) | Set-Content -LiteralPath $cleanupScript -Encoding ascii

$cleanupProcess = [System.Diagnostics.ProcessStartInfo]::new()
$cleanupProcess.FileName = $env:ComSpec
$cleanupProcess.Arguments = "/d /c `"$cleanupScript`""
$cleanupProcess.WorkingDirectory = $env:TEMP
$cleanupProcess.UseShellExecute = $true
$cleanupProcess.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
[System.Diagnostics.Process]::Start($cleanupProcess) | Out-Null
