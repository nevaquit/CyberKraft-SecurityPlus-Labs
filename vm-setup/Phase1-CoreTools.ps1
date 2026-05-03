# =============================================================================
# CyberKraft Security+ Labs - Phase 1: Core Tools Installation
# VM: HenryVM | OS: Windows Server 2025 Datacenter Azure Edition
# Executed via: Azure Run Command (RunPowerShellScript)
# =============================================================================

Write-Host "=== CyberKraft Lab Setup: Phase 1 ===" -ForegroundColor Cyan
Write-Host "Starting installation on HenryVM - Windows Server 2025" -ForegroundColor Green

# Set execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Chocolatey package manager
Write-Host "`n[1/5] Installing Chocolatey..." -ForegroundColor Yellow
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
try {
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Chocolatey installed successfully." -ForegroundColor Green
} catch {
    Write-Host "Chocolatey install error: $_" -ForegroundColor Red
}

# Refresh environment
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install Wireshark (Lab 02 - Network Traffic Analysis)
Write-Host "`n[2/5] Installing Wireshark..." -ForegroundColor Yellow
try {
    choco install wireshark -y --no-progress
    Write-Host "Wireshark installed." -ForegroundColor Green
} catch {
    Write-Host "Wireshark install error: $_" -ForegroundColor Red
}

# Install Git (version control for lab scripts)
Write-Host "`n[3/5] Installing Git..." -ForegroundColor Yellow
try {
    choco install git -y --no-progress
    Write-Host "Git installed." -ForegroundColor Green
} catch {
    Write-Host "Git install error: $_" -ForegroundColor Red
}

# Install Nmap (Lab 05 - Vulnerability Scanning context)
Write-Host "`n[4/5] Installing Nmap..." -ForegroundColor Yellow
try {
    choco install nmap -y --no-progress
    Write-Host "Nmap installed." -ForegroundColor Green
} catch {
    Write-Host "Nmap install error: $_" -ForegroundColor Red
}

# Create lab directory structure
Write-Host "`n[5/5] Creating CyberKraft lab directory structure..." -ForegroundColor Yellow
$labRoot = "C:\CyberKraft-Labs"
$dirs = @(
    "$labRoot\Lab01-ActiveDirectory\scripts",
    "$labRoot\Lab01-ActiveDirectory\reports",
    "$labRoot\Lab02-Wireshark\captures",
    "$labRoot\Lab02-Wireshark\reports",
    "$labRoot\Lab03-Splunk\configs",
    "$labRoot\Lab03-Splunk\queries",
    "$labRoot\Lab04-ServiceNow\workflows",
    "$labRoot\Lab05-Nessus\scans",
    "$labRoot\Lab05-Nessus\remediation",
    "$labRoot\Lab06-AzureCloud\scripts",
    "$labRoot\Lab06-AzureCloud\reports",
    "$labRoot\Logs"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}
Write-Host "Lab directories created at $labRoot" -ForegroundColor Green

# Log setup info
$logEntry = @"
CyberKraft Lab Setup Log
========================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
VM: HenryVM
OS: Windows Server 2025 Datacenter Azure Edition
Phase: 1 - Core Tools Installation
Tools Installed: Chocolatey, Wireshark, Git, Nmap
Lab Root: C:\CyberKraft-Labs
"@
$logEntry | Out-File "$labRoot\Logs\setup-phase1.log" -Encoding UTF8

Write-Host "`n=== Phase 1 Setup Complete ===" -ForegroundColor Cyan
Write-Host "Lab root: $labRoot" -ForegroundColor Green
Get-ChildItem $labRoot -Recurse -Directory | Select-Object FullName
