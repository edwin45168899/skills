# diagnose.ps1 - Project Stack Diagnostic Tool

Write-Host "`n🔍 Starting Debug Wizard Diagnostic..." -ForegroundColor Cyan

# 1. Check Docker Service
Write-Host "`n[1/3] Checking Docker Service Status..." -ForegroundColor Yellow
$dockerProcess = Get-Process docker -ErrorAction SilentlyContinue
if ($dockerProcess) {
    Write-Host "Docker is running (Process ID: $($dockerProcess.Id))." -ForegroundColor Green
} else {
    Write-Host "Warning: Docker process not found. Is Docker Desktop running?" -ForegroundColor Red
}

# 2. Check Container Status
Write-Host "`n[2/3] Checking Docker Containers..." -ForegroundColor Yellow
try {
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
} catch {
    Write-Host "Error executing docker command. Please ensure docker is in your PATH." -ForegroundColor Red
}

# 3. Check Critical Ports
Write-Host "`n[3/3] Checking Critical Ports..." -ForegroundColor Yellow
$targetPorts = @(
    @{Port=80; Service="App Server"},
    @{Port=3000; Service="Grafana"},
    @{Port=3100; Service="Loki"},
    @{Port=9090; Service="Prometheus"},
    @{Port=9100; Service="Node Exporter"},
    @{Port=8080; Service="cAdvisor"}
)

foreach ($item in $targetPorts) {
    $port = $item.Port
    $service = $item.Service
    
    # Using Test-NetConnection is robust but can be slow on failure. 
    # Using Get-NetTCPConnection for local check is faster.
    $listening = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    
    if ($listening) {
        Write-Host "[OK] Port $port ($service) is LISTENING." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Port $port ($service) is NOT listening." -ForegroundColor Red
    }
}

Write-Host "`n✅ Diagnostic Complete." -ForegroundColor Cyan
