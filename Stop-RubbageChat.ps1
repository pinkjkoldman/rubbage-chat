$ErrorActionPreference = 'Stop'

$deployDirectory = if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'RubbageChat.exe')) {
    $PSScriptRoot
}
else {
    Join-Path $PSScriptRoot 'deploy'
}
$expectedExecutables = @(
    (Join-Path $deployDirectory 'RubbageChat.exe'),
    (Join-Path $deployDirectory 'RubbageChatServer.exe')
)

Get-Process -Name 'RubbageChat', 'RubbageChatServer' -ErrorAction SilentlyContinue |
    Where-Object { $expectedExecutables -contains $_.Path } |
    Stop-Process
