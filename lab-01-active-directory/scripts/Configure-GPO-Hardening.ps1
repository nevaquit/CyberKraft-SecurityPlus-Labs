# ============================================================
# CyberKraft Security+ Lab 01 — Active Directory
# Script: Configure-GPO-Hardening.ps1
# Purpose: Create and configure security GPOs via PowerShell
# Author: Henry Jenkins | CyberKraft Training
# Azure VM: HenryVM (South Africa North)
# SY0-701 Domain: 4.6 Hardening
# ============================================================

#Requires -Module GroupPolicy
#Requires -RunAsAdministrator

$Domain = "cyberkraft.local"
$DomainDN = "DC=cyberkraft,DC=local"

function Write-Log {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
}

Write-Log "=== CyberKraft GPO Hardening Script Started ==="

# ---- GPO 1: Password Policy ----
Write-Log "Creating GPO: CK-Password-Policy..."
$GPO1 = New-GPO -Name "CK-Password-Policy" -Comment "CyberKraft password complexity and lockout policy"
New-GPLink -Name "CK-Password-Policy" -Target $DomainDN -LinkEnabled Yes

# Password settings via secedit (requires exporting/importing security template)
$PasswordTemplate = @"
[Unicode]
Unicode=yes
[System Access]
MinimumPasswordAge = 1
MaximumPasswordAge = 90
MinimumPasswordLength = 12
PasswordComplexity = 1
PasswordHistorySize = 24
LockoutBadCount = 5
ResetLockoutCount = 30
LockoutDuration = 30
[Version]
signature=`"`$CHICAGO`$`"
Revision=1
"@

$TemplateFile = "C:\Scripts\password_policy.inf"
$PasswordTemplate | Out-File -FilePath $TemplateFile -Encoding Unicode
secedit /configure /db C:\Windows\security\database\secedit.sdb /cfg $TemplateFile /areas SECURITYPOLICY
Write-Log "Password policy applied via secedit."

# ---- GPO 2: Audit Policy ----
Write-Log "Creating GPO: CK-Audit-Policy..."
$GPO2 = New-GPO -Name "CK-Audit-Policy" -Comment "CyberKraft advanced audit logging policy"
New-GPLink -Name "CK-Audit-Policy" -Target $DomainDN -LinkEnabled Yes

# Apply audit settings using auditpol
$AuditSettings = @(
    @{ Category = "Account Logon";      Success = $true; Failure = $true  },
    @{ Category = "Account Management"; Success = $true; Failure = $true  },
    @{ Category = "Logon/Logoff";       Success = $true; Failure = $true  },
    @{ Category = "Object Access";      Success = $true; Failure = $true  },
    @{ Category = "Policy Change";      Success = $true; Failure = $false },
    @{ Category = "Privilege Use";      Success = $false; Failure = $true }
)

foreach ($Audit in $AuditSettings) {
    $SuccessFlag = if ($Audit.Success) { "enable" } else { "disable" }
    $FailureFlag = if ($Audit.Failure) { "enable" } else { "disable" }
    auditpol /set /category:"$($Audit.Category)" /success:$SuccessFlag /failure:$FailureFlag
    Write-Log "  Audit set: $($Audit.Category) | Success=$($Audit.Success) | Failure=$($Audit.Failure)"
}

# ---- GPO 3: Screensaver Lock ----
Write-Log "Creating GPO: CK-Screensaver-Lock..."
$GPO3 = New-GPO -Name "CK-Screensaver-Lock" -Comment "CyberKraft screensaver and session lock policy"
New-GPLink -Name "CK-Screensaver-Lock" -Target $DomainDN -LinkEnabled Yes

Set-GPRegistryValue -Name "CK-Screensaver-Lock" `
    -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -ValueName "ScreenSaveActive" -Type String -Value "1"

Set-GPRegistryValue -Name "CK-Screensaver-Lock" `
    -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -ValueName "ScreenSaverIsSecure" -Type String -Value "1"

Set-GPRegistryValue -Name "CK-Screensaver-Lock" `
    -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -ValueName "ScreenSaveTimeOut" -Type String -Value "600"

Write-Log "Screensaver lock policy configured (600 second timeout, password required)."

# ---- GPO 4: Disable USB Storage ----
Write-Log "Creating GPO: CK-Disable-USB-Storage..."
$GPO4 = New-GPO -Name "CK-Disable-USB-Storage" -Comment "Disable removable storage devices"
New-GPLink -Name "CK-Disable-USB-Storage" -Target $DomainDN -LinkEnabled Yes

Set-GPRegistryValue -Name "CK-Disable-USB-Storage" `
    -Key "HKLM\SYSTEM\CurrentControlSet\Services\USBSTOR" `
    -ValueName "Start" -Type DWord -Value 4

Write-Log "USB storage disabled via registry GPO."

# ---- GPO 5: Windows Firewall ----
Write-Log "Creating GPO: CK-Windows-Firewall..."
$GPO5 = New-GPO -Name "CK-Windows-Firewall" -Comment "Enable Windows Firewall on all profiles"
New-GPLink -Name "CK-Windows-Firewall" -Target $DomainDN -LinkEnabled Yes

# Enable firewall for Domain, Private, Public profiles
Set-GPRegistryValue -Name "CK-Windows-Firewall" `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" `
    -ValueName "EnableFirewall" -Type DWord -Value 1

Set-GPRegistryValue -Name "CK-Windows-Firewall" `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" `
    -ValueName "EnableFirewall" -Type DWord -Value 1

Set-GPRegistryValue -Name "CK-Windows-Firewall" `
    -Key "HKLM\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" `
    -ValueName "EnableFirewall" -Type DWord -Value 1

Write-Log "Windows Firewall enabled on all profiles."

# ---- Summary ----
Write-Log "=== GPO Configuration Complete ==="
Write-Log "GPOs Created:"
Get-GPO -All | Where-Object { $_.DisplayName -like "CK-*" } |
    Select-Object DisplayName, GpoStatus, CreationTime |
    Format-Table -AutoSize

# Force GPO update
Write-Log "Forcing GPO update on local machine..."
gpupdate /force /wait:0

Write-Log "Run 'gpresult /R' on any domain-joined machine to verify GPO application."
