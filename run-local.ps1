param(
    [switch]$SkipTests,
    [switch]$BuildOnly,
    [switch]$SeedDemo,
    [switch]$SeedOnly
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$dbUrl = "jdbc:mysql://localhost:3307/mediqueue?useSSL=false&serverTimezone=Asia/Kuala_Lumpur&allowPublicKeyRetrieval=true"
$warPath = Join-Path $projectRoot "target\mediqueue.war"
$seedDemoPath = Join-Path $projectRoot "sql\mediqueue_seed_demo.sql"

Write-Host "==> Starting MediQueue local helper..." -ForegroundColor Cyan

function Get-TomcatHome {
    if ($env:CATALINA_HOME -and (Test-Path $env:CATALINA_HOME)) {
        return $env:CATALINA_HOME
    }

    $commonCandidates = @(
        "C:\apache-tomcat-11.0.0",
        "C:\apache-tomcat-11.0.1",
        "C:\apache-tomcat-11.0.2",
        "C:\apache-tomcat-11.0.3",
        "C:\apache-tomcat-11.0.4",
        "C:\apache-tomcat-11.0.5",
        "C:\apache-tomcat-11.0.6",
        "C:\apache-tomcat-11.0.7",
        "C:\apache-tomcat-11.0.8",
        "C:\apache-tomcat-11.0.9",
        "C:\apache-tomcat-11.0.10",
        "C:\apache-tomcat-11.0.11"
    )

    foreach ($candidate in $commonCandidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Invoke-DemoSeed {
    if (-not (Test-Path $seedDemoPath)) {
        throw "Demo seed script not found at $seedDemoPath"
    }

    Write-Host "==> Seeding demo data into MySQL..." -ForegroundColor Yellow
    Get-Content -Raw $seedDemoPath | docker compose exec -T db mysql -h 127.0.0.1 -uroot -proot mediqueue | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Demo seed failed."
    }

    Write-Host "Demo data seed complete." -ForegroundColor Green
}

function Wait-ForDatabase {
    $maxAttempts = 30

    Write-Host "==> Waiting for MySQL to become ready..." -ForegroundColor Yellow
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        docker compose exec -T db mysqladmin ping -h 127.0.0.1 -uroot -proot --silent | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "MySQL is ready." -ForegroundColor Green
            return
        }

        Start-Sleep -Seconds 2
    }

    throw "MySQL did not become ready in time."
}

Push-Location $projectRoot
try {
    Write-Host "==> Ensuring Docker MySQL is running..." -ForegroundColor Yellow
    docker compose up -d db | Out-Host
    Wait-ForDatabase

    Write-Host "==> Setting MediQueue database environment for this shell..." -ForegroundColor Yellow
    $env:MEDIQUEUE_DB_URL = $dbUrl
    $env:MEDIQUEUE_DB_USERNAME = "root"
    $env:MEDIQUEUE_DB_PASSWORD = "root"

    if ($SeedDemo -or $SeedOnly) {
        Invoke-DemoSeed
    }

    if ($SeedOnly) {
        Write-Host ""
        Write-Host "Seed-only mode enabled; no build or deploy was run." -ForegroundColor Green
        Write-Host "Tip: run '.\run-local.ps1 -SeedDemo -SkipTests' to reseed and launch the app." -ForegroundColor DarkGray
        return
    }

    $mavenArgs = @("clean", "package")
    if ($SkipTests) {
        $mavenArgs += "-DskipTests"
    }

    Write-Host "==> Running: mvn $($mavenArgs -join ' ')" -ForegroundColor Yellow
    & mvn @mavenArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Maven build failed."
    }

    Write-Host ""
    Write-Host "Build complete." -ForegroundColor Green
    Write-Host "DB URL for this shell: $env:MEDIQUEUE_DB_URL"

    if ($BuildOnly) {
        Write-Host "Build-only mode enabled; WAR is ready at $warPath"
        Write-Host ""
        Write-Host "Tip: run '.\run-local.ps1 -SeedDemo -SkipTests' when you want a quick rebuild with demo data." -ForegroundColor DarkGray
        return
    }

    $tomcatHome = Get-TomcatHome
    if (-not $tomcatHome) {
        Write-Host ""
        Write-Host "Tomcat was not found, so the website was not started." -ForegroundColor Yellow
        Write-Host "Install Tomcat 11 and set CATALINA_HOME, or extract it to a folder like C:\apache-tomcat-11.0.x"
        Write-Host "Then rerun .\run-local.ps1 and it will deploy automatically."
        return
    }

    $webappsPath = Join-Path $tomcatHome "webapps"
    $startupScript = Join-Path $tomcatHome "bin\startup.bat"
    $shutdownScript = Join-Path $tomcatHome "bin\shutdown.bat"
    $explodedApp = Join-Path $webappsPath "mediqueue"
    $deployedWar = Join-Path $webappsPath "mediqueue.war"

    if (-not (Test-Path $startupScript)) {
        throw "Tomcat startup script not found at $startupScript"
    }

    Write-Host "==> Deploying WAR to Tomcat at $tomcatHome..." -ForegroundColor Yellow
    if (Test-Path $shutdownScript) {
        & $shutdownScript | Out-Host
        Start-Sleep -Seconds 3
    }

    if (Test-Path $explodedApp) {
        Remove-Item -LiteralPath $explodedApp -Recurse -Force
    }
    if (Test-Path $deployedWar) {
        Remove-Item -LiteralPath $deployedWar -Force
    }

    Copy-Item -LiteralPath $warPath -Destination $deployedWar -Force

    Write-Host "==> Starting Tomcat..." -ForegroundColor Yellow
    & $startupScript | Out-Host

    Write-Host ""
    Write-Host "MediQueue should be available at http://localhost:8080/mediqueue/" -ForegroundColor Green
    Write-Host "Login: admin@mediqueue.my / admin123"
    Write-Host "Tip: run '.\run-local.ps1 -SeedDemo -SkipTests' for a quicker rebuild with demo data." -ForegroundColor DarkGray
} finally {
    Pop-Location
}
