$ErrorActionPreference = "Stop"

$webConfigPath = "C:\inetpub\wwwroot\Web.config"
$connectionStringFromEnv = $env:SOFTINSA_BADGES_CONNSTR

if (-not [string]::IsNullOrWhiteSpace($connectionStringFromEnv) -and (Test-Path $webConfigPath)) {
    [xml]$config = Get-Content -Path $webConfigPath
    $node = $config.SelectSingleNode("/configuration/connectionStrings/add[@name='SoftinsaBadgesDb']")

    if ($null -ne $node) {
        $node.SetAttribute("connectionString", $connectionStringFromEnv)
        $config.Save($webConfigPath)
        Write-Host "Connection string 'SoftinsaBadgesDb' atualizada por variável de ambiente."
    }
}

Write-Host "A iniciar IIS (w3svc)..."
& C:\ServiceMonitor.exe w3svc
