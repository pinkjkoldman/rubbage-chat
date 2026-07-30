$ErrorActionPreference = 'Stop'

$packageDirectory = $PSScriptRoot
$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\RubbageChat'
$archive = Join-Path $packageDirectory 'RubbageChatPayload.7z'
$sevenZip = Join-Path $packageDirectory '7z.exe'

if (-not (Test-Path -LiteralPath $archive) -or -not (Test-Path -LiteralPath $sevenZip)) {
    throw 'The installer payload is incomplete'
}

New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
$installedExecutables = @(
    (Join-Path $installDirectory 'RubbageChat.exe'),
    (Join-Path $installDirectory 'RubbageChatServer.exe')
)
Get-Process RubbageChat, RubbageChatServer -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $installedExecutables -contains $_.Path } |
    Stop-Process -Force

& $sevenZip x $archive "-o$installDirectory" -aoa -y | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to extract the RubbageChat application files'
}

$shell = New-Object -ComObject WScript.Shell
$powershell = Join-Path $PSHOME 'powershell.exe'
$launcher = Join-Path $installDirectory 'Start-RubbageChat.ps1'
$uninstaller = Join-Path $installDirectory 'Uninstall-RubbageChat.ps1'
$icon = Join-Path $installDirectory 'RubbageChat.exe'

function New-RubbageChatShortcut([string]$path, [string]$script) {
    $shortcut = $shell.CreateShortcut($path)
    $shortcut.TargetPath = $powershell
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
    $shortcut.WorkingDirectory = $installDirectory
    $shortcut.IconLocation = "$icon,0"
    $shortcut.Save()
}

$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'RubbageChat.lnk'
$startMenuDirectory = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\RubbageChat'
New-Item -ItemType Directory -Path $startMenuDirectory -Force | Out-Null
New-RubbageChatShortcut $desktopShortcut $launcher
New-RubbageChatShortcut (Join-Path $startMenuDirectory 'RubbageChat.lnk') $launcher
New-RubbageChatShortcut (Join-Path $startMenuDirectory 'Uninstall RubbageChat.lnk') $uninstaller

$uninstallKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\RubbageChat'
New-Item -Path $uninstallKey -Force | Out-Null
Set-ItemProperty -Path $uninstallKey -Name DisplayName -Value 'RubbageChat'
Set-ItemProperty -Path $uninstallKey -Name DisplayVersion -Value '2.1.0'
Set-ItemProperty -Path $uninstallKey -Name Publisher -Value 'RubbageChat'
Set-ItemProperty -Path $uninstallKey -Name InstallLocation -Value $installDirectory
Set-ItemProperty -Path $uninstallKey -Name DisplayIcon -Value $icon
Set-ItemProperty -Path $uninstallKey -Name UninstallString `
    -Value "`"$powershell`" -NoProfile -ExecutionPolicy Bypass -File `"$uninstaller`""
New-ItemProperty -Path $uninstallKey -Name NoModify -Value 1 `
    -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $uninstallKey -Name NoRepair -Value 1 `
    -PropertyType DWord -Force | Out-Null

& $powershell -NoProfile -ExecutionPolicy Bypass -File $launcher
