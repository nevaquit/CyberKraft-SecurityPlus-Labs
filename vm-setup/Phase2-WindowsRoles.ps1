# =============================================================================
# CyberKraft Security+ Labs - Phase 2: Windows Server Roles & Features
# VM: HenryVM | OS: Windows Server 2025 Datacenter Azure Edition
# Executed via: Azure Run Command (RunPowerShellScript)
# =============================================================================

Write-Host "=== CyberKraft Lab Setup: Phase 2 ===" -ForegroundColor Cyan
Write-Host "Installing Windows Server roles and features..." -ForegroundColor Green

$labRoot = "C:\CyberKraft-Labs"

# Install AD DS, DNS, RSAT tools (Lab 01)
Write-Host "`n[1/4] Installing AD DS and DNS roles..." -ForegroundColor Yellow
try {
    Install-WindowsFeature -Name AD-Domain-Services, DNS, RSAT-AD-Tools, RSAT-DNS-Server -IncludeManagementTools -ErrorAction Stop
    Write-Host "AD DS and DNS roles installed successfully." -ForegroundColor Green
} catch {
    Write-Host "AD DS install error: $_" -ForegroundColor Red
}

# Configure Windows Defender (Security+ Domain 4.1)
Write-Host "`n[2/4] Configuring Windows Defender..." -ForegroundColor Yellow
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -EnableNetworkProtection Enabled
    Set-MpPreference -EnableControlledFolderAccess Enabled
    Set-MpPreference -CloudBlockLevel High
    Write-Host "Windows Defender configured." -ForegroundColor Green
} catch {
    Write-Host "Defender config error: $_" -ForegroundColor Red
}

# Enable Windows Event Logging for SIEM (Lab 03 - Splunk)
Write-Host "`n[3/4] Enabling Windows Event Logging for SIEM..." -ForegroundColor Yellow
try {
    $logs = @(
        "Security",
        "System",
        "Application",
        "Microsoft-Windows-PowerShell/Operational"
    )
    foreach ($log in $logs) {
        try {
            wevtutil sl $log /e:true /ms:104857600
            Write-Host "  Enabled: $log" -ForegroundColor Green
        } catch {
            Write-Host "  Skipped: $log" -ForegroundColor Gray
        }
    }

    # Configure comprehensive audit policies (Security+ Domain 4.3)
    auditpol /set /category:"Account Logon" /success:enable /failure:enable
    auditpol /set /category:"Account Management" /success:enable /failure:enable
    auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
    auditpol /set /category:"Object Access" /success:enable /failure:enable
    auditpol /set /category:"Policy Change" /success:enable /failure:enable
    auditpol /set /category:"Privilege Use" /success:enable /failure:enable
    auditpol /set /category:"System" /success:enable /failure:enable
    auditpol /set /category:"Detailed Tracking" /success:enable /failure:enable
    Write-Host "Audit policies configured." -ForegroundColor Green
} catch {
    Write-Host "Event logging error: $_" -ForegroundColor Red
}

# Download Splunk Universal Forwarder (Lab 03)
Write-Host "`n[4/4] Downloading Splunk Universal Forwarder..." -ForegroundColor Yellow
try {
    $splunkUrl = "https://download.splunk.com/products/universalforwarder/releases/9.2.1/windows/splunkforwarder-9.2.1-78803f08aabb-x64-release.msi"
    $splunkDest = "$labRoot\Lab03-Splunk\splunkforwarder-9.2.1-x64.msi"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($splunkUrl, $splunkDest)
    Write-Host "Splunk forwarder downloaded to $splunkDest" -ForegroundColor Green
} catch {
    Write-Host "Splunk download note (manual install required): $_" -ForegroundColor Yellow
}

# Log phase 2 completion
$logEntry = @"
CyberKraft Lab Setup Log - Phase 2
====================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Roles Installed: AD-Domain-Services, DNS, RSAT-AD-Tools, RSAT-DNS-Server
Audit Policies: Account Logon, Account Management, Logon/Logoff, Object Access, Policy Change, Privilege Use, System, Detailed Tracking
Windows Defender: Real-time protection enabled, Network protection enabled, Controlled folder access enabled
"@
$logEntry | Out-File "$labRoot\Logs\setup-phase2.log" -Encoding UTF8

Write-Host "`n=== Phase 2 Complete ===" -ForegroundColor Cyan
Get-WindowsFeature | Where-Object {$_.InstallState -eq "Installed" -and $_.Name -match "AD|DNS|RSAT"} | Select-Object Name, DisplayName, InstallState
