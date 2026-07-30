$ErrorActionPreference = 'Stop'

$packageDirectory = $PSScriptRoot
$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\RubbageChat'
$archive = Join-Path $packageDirectory 'RubbageChatPayload.7z'
$sevenZip = Join-Path $packageDirectory '7z.exe'

if (-not (Test-Path -LiteralPath $archive) -or -not (Test-Path -LiteralPath $sevenZip)) {
    throw 'The installer payload is incomplete'
}

New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
$installedExecutable = Join-Path $installDirectory 'RubbageChat.exe'
Get-Process RubbageChat -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path -eq $installedExecutable } |
    Stop-Process -Force

& $sevenZip x $archive "-o$installDirectory" -aoa -y | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to extract the RubbageChat application files'
}

$shell = New-Object -ComObject WScript.Shell
$powershell = Join-Path $PSHOME 'powershell.exe'
$launcher = Join-Path $installDirectory 'RubbageChat.exe'
$uninstaller = Join-Path $installDirectory 'Uninstall-RubbageChat.ps1'
$icon = Join-Path $installDirectory 'RubbageChat.exe'

function New-ApplicationShortcut([string]$path) {
    $shortcut = $shell.CreateShortcut($path)
    $shortcut.TargetPath = $launcher
    $shortcut.WorkingDirectory = $installDirectory
    $shortcut.IconLocation = "$icon,0"
    $shortcut.Save()
}

function New-UninstallShortcut([string]$path) {
    $shortcut = $shell.CreateShortcut($path)
    $shortcut.TargetPath = $powershell
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstaller`""
    $shortcut.WorkingDirectory = $installDirectory
    $shortcut.IconLocation = "$icon,0"
    $shortcut.Save()
}

$desktopShortcut = Join-Path ([Environment]::GetFolderPath('Desktop')) 'RubbageChat.lnk'
$startMenuDirectory = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\RubbageChat'
New-Item -ItemType Directory -Path $startMenuDirectory -Force | Out-Null
New-ApplicationShortcut $desktopShortcut
New-ApplicationShortcut (Join-Path $startMenuDirectory 'RubbageChat.lnk')
New-UninstallShortcut (Join-Path $startMenuDirectory 'Uninstall RubbageChat.lnk')

$uninstallKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\RubbageChat'
New-Item -Path $uninstallKey -Force | Out-Null
Set-ItemProperty -Path $uninstallKey -Name DisplayName -Value 'RubbageChat'
Set-ItemProperty -Path $uninstallKey -Name DisplayVersion -Value '2.5.0-beta.1'
Set-ItemProperty -Path $uninstallKey -Name Publisher -Value 'RubbageChat'
Set-ItemProperty -Path $uninstallKey -Name InstallLocation -Value $installDirectory
Set-ItemProperty -Path $uninstallKey -Name DisplayIcon -Value $icon
Set-ItemProperty -Path $uninstallKey -Name UninstallString `
    -Value "`"$powershell`" -NoProfile -ExecutionPolicy Bypass -File `"$uninstaller`""
New-ItemProperty -Path $uninstallKey -Name NoModify -Value 1 `
    -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $uninstallKey -Name NoRepair -Value 1 `
    -PropertyType DWord -Force | Out-Null

Start-Process -FilePath $launcher -WorkingDirectory $installDirectory
