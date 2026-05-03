# =============================================================================
# CyberKraft Security+ Labs - Phase 5: Nessus Essentials Silent Install
# Target: HenryVM (Windows Server 2025 Datacenter)
# Method: msiexec.exe with /qn flag - NO GUI required
# Run via: Azure Portal > HenryVM > Operations > Run Command > RunPowerShellScript
# NOTE: After install, activate at https://www.tenable.com/products/nessus/nessus-essentials
# =============================================================================

$NessusVersion = "10.7.4"
$NessusMSI     = "Nessus-${NessusVersion}-x64.msi"
$DownloadURL   = "https://www.tenable.com/downloads/api/v2/pages/nessus/files/${NessusMSI}"
$DestPath      = "C:\CyberKraft-Labs\Lab05-Nessus\${NessusMSI}"
$LogFile       = "C:\CyberKraft-Labs\Lab05-Nessus\nessus-install.log"

Write-Output "[1/4] Creating directories..."
New-Item -ItemType Directory -Force -Path "C:\CyberKraft-Labs\Lab05-Nessus" | Out-Null

Write-Output "[2/4] Downloading Nessus Essentials ${NessusVersion}..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # Use Invoke-WebRequest with Tenable's direct download API
    $Headers = @{ "Accept" = "application/octet-stream" }
    Invoke-WebRequest -Uri $DownloadURL -OutFile $DestPath -Headers $Headers -UseBasicParsing
    Write-Output "Download complete: $DestPath ($('{0:N0}' -f (Get-Item $DestPath).Length) bytes)"
} catch {
    Write-Output "Primary download failed: $_"
    Write-Output "Trying alternative Tenable CDN..."
    try {
        $AltURL = "https://downloads.nessus.org/nessus3dl.php?file=${NessusMSI}&licence_accept=yes&t=b1b7e8b7e8b7e8b7e8b7e8b7e8b7e8b7"
        Invoke-WebRequest -Uri $AltURL -OutFile $DestPath -UseBasicParsing
        Write-Output "Alternative download complete"
    } catch {
        Write-Output "ERROR: Could not download Nessus. Please download manually from:"
        Write-Output "https://www.tenable.com/downloads/nessus"
        Write-Output "Save to: $DestPath"
        Write-Output "Then re-run steps [3/4] and [4/4] only."
        exit 1
    }
}

Write-Output "[3/4] Running silent MSI install..."
# Key flags:
#   /qn                   - Completely silent, no GUI (quiet, no UI)
#   /norestart            - Prevents automatic reboot
#   ACCEPTLICENSE=YES     - Accepts EULA without GUI prompt
#   /l*v                  - Verbose log for troubleshooting
$MSIArgs = @(
    "/i", "`"$DestPath`"",
    "ACCEPTLICENSE=YES",
    "/qn",
    "/norestart",
    "/l*v", "`"$LogFile`""
)
$proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $MSIArgs -Wait -PassThru
Write-Output "MSI exit code: $($proc.ExitCode)"

Write-Output "[4/4] Verifying installation and starting service..."
$NessusService = Get-Service -Name "Tenable Nessus" -ErrorAction SilentlyContinue
if ($NessusService) {
    Write-Output "Nessus service found: $($NessusService.Status)"
    if ($NessusService.Status -ne "Running") {
        Start-Service -Name "Tenable Nessus"
        Start-Sleep -Seconds 5
        $NessusService.Refresh()
        Write-Output "Service started: $($NessusService.Status)"
    }
    Write-Output ""
    Write-Output "=== NESSUS INSTALLED SUCCESSFULLY ==="
    Write-Output "Web UI: https://localhost:8834"
    Write-Output "NEXT STEP: Open browser to https://localhost:8834"
    Write-Output "           Select 'Nessus Essentials' and enter activation code"
    Write-Output "           Get free code at: https://www.tenable.com/products/nessus/nessus-essentials"
} else {
    Write-Output "Nessus service not found - checking log..."
    if (Test-Path $LogFile) {
        Get-Content $LogFile | Select-Object -Last 30
    }
}
Write-Output "=== Nessus Silent Install Complete ==="
