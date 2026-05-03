# =============================================================================
# CyberKraft Security+ Labs - Phase 4: Splunk Enterprise Silent Install
# Target: HenryVM (Windows Server 2025 Datacenter)
# Method: msiexec.exe with /quiet /norestart flags - NO GUI required
# Run via: Azure Portal > HenryVM > Operations > Run Command > RunPowerShellScript
# =============================================================================

$SplunkVersion = "9.3.2"
$SplunkBuild   = "d8bb32809498"
$SplunkMSI     = "splunk-${SplunkVersion}-${SplunkBuild}-x64-release.msi"
$DownloadURL   = "https://download.splunk.com/products/splunk/releases/${SplunkVersion}/windows/${SplunkMSI}"
$DestPath      = "C:\CyberKraft-Labs\Lab03-Splunk\${SplunkMSI}"
$LogFile       = "C:\CyberKraft-Labs\Lab03-Splunk\splunk-install.log"
$SplunkHome    = "C:\Splunk"

Write-Output "[1/4] Creating directories..."
New-Item -ItemType Directory -Force -Path "C:\CyberKraft-Labs\Lab03-Splunk" | Out-Null
New-Item -ItemType Directory -Force -Path $SplunkHome | Out-Null

Write-Output "[2/4] Downloading Splunk Enterprise ${SplunkVersion}..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($DownloadURL, $DestPath)
    Write-Output "Download complete: $DestPath"
} catch {
    Write-Output "ERROR downloading: $_"
    exit 1
}

Write-Output "[3/4] Running silent MSI install..."
# Key flags:
#   AGREETOLICENSE=Yes    - Accepts EULA without GUI prompt
#   SPLUNKPASSWORD=...    - Sets admin password without GUI prompt
#   /quiet                - Completely silent, no GUI windows
#   /norestart            - Prevents automatic reboot
#   /l*v                  - Verbose log for troubleshooting
$MSIArgs = @(
    "/i", "`"$DestPath`"",
    "INSTALLDIR=`"$SplunkHome`"",
    "AGREETOLICENSE=Yes",
    "SPLUNKPASSWORD=CyberKraft@2025",
    "WINEVENTLOG_APP_ENABLE=1",
    "WINEVENTLOG_SEC_ENABLE=1",
    "WINEVENTLOG_SYS_ENABLE=1",
    "LAUNCHSPLUNK=1",
    "/quiet",
    "/norestart",
    "/l*v", "`"$LogFile`""
)
$proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $MSIArgs -Wait -PassThru
Write-Output "MSI exit code: $($proc.ExitCode)"

Write-Output "[4/4] Verifying installation..."
if (Test-Path "$SplunkHome\bin\splunk.exe") {
    $ver = & "$SplunkHome\bin\splunk.exe" version --accept-license --answer-yes --no-prompt 2>$null
    Write-Output "SPLUNK INSTALLED: $ver"
    Write-Output "Web UI: http://localhost:8000"
    Write-Output "Credentials: admin / CyberKraft@2025"
} else {
    Write-Output "Splunk binary not found - checking install log..."
    if (Test-Path $LogFile) {
        Get-Content $LogFile | Select-Object -Last 30
    }
}
Write-Output "=== Splunk Silent Install Complete ==="
