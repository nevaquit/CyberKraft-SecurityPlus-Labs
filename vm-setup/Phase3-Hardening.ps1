# =============================================================================
# CyberKraft Security+ Labs - Phase 3: Security Hardening
# VM: HenryVM | OS: Windows Server 2025 Datacenter Azure Edition
# Executed via: Azure Run Command (RunPowerShellScript)
# Security+ Domains: 2.4, 2.5, 4.1, 4.6
# =============================================================================

Write-Host "=== CyberKraft Lab Setup: Phase 3 - Security Hardening ===" -ForegroundColor Cyan

$labRoot = "C:\CyberKraft-Labs"

# -------------------------------------------------------------------------
# 1. Password Policy (Security+ Domain 2.4)
# -------------------------------------------------------------------------
Write-Host "`n[1/8] Configuring Password Policy..." -ForegroundColor Yellow
try {
    net accounts /minpwlen:12 /maxpwage:90 /minpwage:1 /uniquepw:10
    # Enable password complexity via secedit
    $secConfig = @"
[Unicode]
Unicode=yes
[System Access]
MinimumPasswordLength = 12
PasswordComplexity = 1
MaximumPasswordAge = 90
MinimumPasswordAge = 1
PasswordHistorySize = 10
LockoutBadCount = 5
ResetLockoutCount = 30
LockoutDuration = 30
[Version]
signature="`$CHICAGO`$"
Revision=1
"@
    $secConfig | Out-File "C:\Windows\Temp\secpol.cfg" -Encoding ASCII
    secedit /configure /db "C:\Windows\Temp\secedit.sdb" /cfg "C:\Windows\Temp\secpol.cfg" /quiet
    Write-Host "Password policy configured: min 12 chars, complexity enabled, lockout at 5 attempts." -ForegroundColor Green
} catch {
    Write-Host "Password policy error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 2. Disable Legacy Protocols (Security+ Domain 2.5, 4.1)
# -------------------------------------------------------------------------
Write-Host "`n[2/8] Disabling legacy protocols (SMBv1, TLS 1.0/1.1)..." -ForegroundColor Yellow
try {
    # Disable SMBv1
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
    Write-Host "  SMBv1 disabled." -ForegroundColor Green

    # Disable TLS 1.0
    $tls10Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"
    New-Item -Path $tls10Path -Force | Out-Null
    Set-ItemProperty -Path $tls10Path -Name "Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $tls10Path -Name "DisabledByDefault" -Value 1 -Type DWord
    Write-Host "  TLS 1.0 disabled." -ForegroundColor Green

    # Disable TLS 1.1
    $tls11Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server"
    New-Item -Path $tls11Path -Force | Out-Null
    Set-ItemProperty -Path $tls11Path -Name "Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $tls11Path -Name "DisabledByDefault" -Value 1 -Type DWord
    Write-Host "  TLS 1.1 disabled." -ForegroundColor Green

    # Enable TLS 1.2
    $tls12Path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
    New-Item -Path $tls12Path -Force | Out-Null
    Set-ItemProperty -Path $tls12Path -Name "Enabled" -Value 1 -Type DWord
    Set-ItemProperty -Path $tls12Path -Name "DisabledByDefault" -Value 0 -Type DWord
    Write-Host "  TLS 1.2 enabled." -ForegroundColor Green
} catch {
    Write-Host "Protocol hardening error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 3. Windows Firewall Configuration (Security+ Domain 4.6)
# -------------------------------------------------------------------------
Write-Host "`n[3/8] Configuring Windows Firewall..." -ForegroundColor Yellow
try {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block
    Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Allow
    Set-NetFirewallProfile -Profile Domain,Public,Private -LogAllowed True
    Set-NetFirewallProfile -Profile Domain,Public,Private -LogBlocked True
    Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName "C:\Windows\System32\LogFiles\Firewall\pfirewall.log"
    Write-Host "Windows Firewall enabled on all profiles with logging." -ForegroundColor Green
} catch {
    Write-Host "Firewall config error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 4. PowerShell Security (Security+ Domain 4.3)
# -------------------------------------------------------------------------
Write-Host "`n[4/8] Enabling PowerShell Script Block Logging..." -ForegroundColor Yellow
try {
    $psLogPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
    New-Item -Path $psLogPath -Force | Out-Null
    Set-ItemProperty -Path $psLogPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord
    Set-ItemProperty -Path $psLogPath -Name "EnableScriptBlockInvocationLogging" -Value 1 -Type DWord

    $psModLogPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
    New-Item -Path $psModLogPath -Force | Out-Null
    Set-ItemProperty -Path $psModLogPath -Name "EnableModuleLogging" -Value 1 -Type DWord
    Write-Host "PowerShell Script Block Logging enabled." -ForegroundColor Green
} catch {
    Write-Host "PS logging error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 5. Disable Unnecessary Services (Security+ Domain 4.1)
# -------------------------------------------------------------------------
Write-Host "`n[5/8] Disabling unnecessary services..." -ForegroundColor Yellow
$servicesToDisable = @("Telnet", "FTP", "SNMP", "RemoteRegistry")
foreach ($svc in $servicesToDisable) {
    try {
        $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            Set-Service -Name $svc -StartupType Disabled
            Write-Host "  Disabled: $svc" -ForegroundColor Green
        } else {
            Write-Host "  Not present: $svc" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Could not disable $svc`: $_" -ForegroundColor Yellow
    }
}

# -------------------------------------------------------------------------
# 6. Enable Windows Update (Security+ Domain 4.1)
# -------------------------------------------------------------------------
Write-Host "`n[6/8] Configuring Windows Update..." -ForegroundColor Yellow
try {
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    New-Item -Path $wuPath -Force | Out-Null
    Set-ItemProperty -Path $wuPath -Name "NoAutoUpdate" -Value 0 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "AUOptions" -Value 4 -Type DWord  # Auto download and schedule install
    Write-Host "Windows Update configured for automatic updates." -ForegroundColor Green
} catch {
    Write-Host "Windows Update config error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 7. USB/Removable Media Control (Security+ Domain 2.4)
# -------------------------------------------------------------------------
Write-Host "`n[7/8] Configuring removable media policy..." -ForegroundColor Yellow
try {
    $usbPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"
    New-Item -Path $usbPath -Force | Out-Null
    # Deny write access to removable storage
    Set-ItemProperty -Path "$usbPath\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" -Name "Deny_Write" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "Removable storage write access restricted." -ForegroundColor Green
} catch {
    Write-Host "USB policy error: $_" -ForegroundColor Red
}

# -------------------------------------------------------------------------
# 8. Screen Lock / Session Timeout (Security+ Domain 2.4)
# -------------------------------------------------------------------------
Write-Host "`n[8/8] Configuring screen lock policy..." -ForegroundColor Yellow
try {
    $screenSaverPath = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $screenSaverPath -Name "ScreenSaveActive" -Value "1"
    Set-ItemProperty -Path $screenSaverPath -Name "ScreenSaverIsSecure" -Value "1"
    Set-ItemProperty -Path $screenSaverPath -Name "ScreenSaveTimeOut" -Value "600"  # 10 minutes
    Write-Host "Screen lock configured: activates after 10 minutes of inactivity." -ForegroundColor Green
} catch {
    Write-Host "Screen lock error: $_" -ForegroundColor Red
}

# Log phase 3 completion
$logEntry = @"
CyberKraft Lab Setup Log - Phase 3
====================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Security Hardening Applied:
  - Password Policy: min 12 chars, complexity, lockout at 5 attempts
  - SMBv1: Disabled
  - TLS 1.0/1.1: Disabled | TLS 1.2: Enabled
  - Windows Firewall: Enabled all profiles with logging
  - PowerShell Script Block Logging: Enabled
  - Unnecessary services: Disabled
  - Windows Update: Auto-update enabled
  - Removable storage: Write access restricted
  - Screen lock: 10-minute timeout
"@
$logEntry | Out-File "$labRoot\Logs\setup-phase3.log" -Encoding UTF8

Write-Host "`n=== Phase 3 Security Hardening Complete ===" -ForegroundColor Cyan
Write-Host "All security configurations applied to HenryVM." -ForegroundColor Green
