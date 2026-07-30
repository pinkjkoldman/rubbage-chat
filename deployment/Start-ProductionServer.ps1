param(
    [string]$Executable = '.\RubbageChatServer.exe'
)

$ErrorActionPreference = 'Stop'

$required = @(
    'RUBBAGECHAT_MONGO_URI',
    'RUBBAGECHAT_TLS_CERT',
    'RUBBAGECHAT_TLS_KEY',
    'RUBBAGECHAT_ATTACHMENT_ROOT'
)
foreach ($name in $required) {
    if (-not [Environment]::GetEnvironmentVariable($name)) {
        throw "Required environment variable is missing: $name"
    }
}

$env:RUBBAGECHAT_PUBLIC_MODE = 'true'
$env:RUBBAGECHAT_TLS = 'true'
$env:RUBBAGECHAT_SEED_DEMO_ACCOUNTS = 'false'

& $Executable --headless
exit $LASTEXITCODE
