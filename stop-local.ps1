$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "==> Stopping MediQueue local DB helper..." -ForegroundColor Cyan

Push-Location $projectRoot
try {
    if ($env:CATALINA_HOME) {
        $shutdownScript = Join-Path $env:CATALINA_HOME "bin\shutdown.bat"
        if (Test-Path $shutdownScript) {
            Write-Host "==> Stopping Tomcat..." -ForegroundColor Yellow
            & $shutdownScript | Out-Host
        }
    }

    docker compose stop db | Out-Host
} finally {
    Pop-Location
}
