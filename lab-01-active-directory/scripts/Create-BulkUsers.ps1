# ============================================================
# CyberKraft Security+ Lab 01 — Active Directory
# Script: Create-BulkUsers.ps1
# Purpose: Bulk-create 50+ AD users from CSV with OU placement
# Author: Henry Jenkins | CyberKraft Training
# Azure VM: HenryVM (South Africa North)
# SY0-701 Domain: 2.4 Identity & Access Management
# ============================================================

#Requires -Module ActiveDirectory
#Requires -RunAsAdministrator

param(
    [string]$CsvPath = "C:\Scripts\users.csv",
    [string]$DefaultPassword = "CyberKraft2024!",
    [string]$Domain = "cyberkraft.local",
    [string]$DomainDN = "DC=cyberkraft,DC=local"
)

# ---- Logging Setup ----
$LogFile = "C:\Scripts\Logs\UserCreation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
New-Item -ItemType Directory -Path "C:\Scripts\Logs" -Force | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "[$Timestamp] [$Level] $Message"
    Write-Host $Entry
    Add-Content -Path $LogFile -Value $Entry
}

Write-Log "=== CyberKraft AD Bulk User Creation Script Started ==="
Write-Log "CSV Path: $CsvPath"
Write-Log "Domain: $Domain"

# ---- Verify CSV exists ----
if (-not (Test-Path $CsvPath)) {
    Write-Log "ERROR: CSV file not found at $CsvPath" "ERROR"
    exit 1
}

# ---- OU Mapping ----
$OUMap = @{
    "Help Desk"     = "OU=Help Desk,OU=_CYBERKRAFT_USERS,$DomainDN"
    "Accounting"    = "OU=Accounting,OU=_CYBERKRAFT_USERS,$DomainDN"
    "IT Admins"     = "OU=IT Admins,OU=_CYBERKRAFT_USERS,$DomainDN"
    "Standard Users"= "OU=Standard Users,OU=_CYBERKRAFT_USERS,$DomainDN"
    "Management"    = "OU=Standard Users,OU=_CYBERKRAFT_USERS,$DomainDN"
    "HR"            = "OU=Standard Users,OU=_CYBERKRAFT_USERS,$DomainDN"
    "Sales"         = "OU=Standard Users,OU=_CYBERKRAFT_USERS,$DomainDN"
}

# ---- Group Mapping ----
$GroupMap = @{
    "Help Desk"     = "GRP_HelpDesk"
    "Accounting"    = "GRP_Accounting"
    "IT Admins"     = "GRP_ITAdmins"
}

# ---- Import and Process CSV ----
$Users = Import-Csv -Path $CsvPath
$TotalUsers = $Users.Count
$CreatedCount = 0
$SkippedCount = 0
$ErrorCount = 0

Write-Log "Total users to process: $TotalUsers"

$SecurePassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force

foreach ($User in $Users) {
    $FirstName  = $User.FirstName.Trim()
    $LastName   = $User.LastName.Trim()
    $Department = $User.Department.Trim()
    $Title      = $User.Title.Trim()
    $Username   = "$($FirstName.ToLower()).$($LastName.ToLower())"
    $UPN        = "$Username@$Domain"
    $FullName   = "$FirstName $LastName"

    # Determine OU
    $TargetOU = if ($OUMap.ContainsKey($Department)) {
        $OUMap[$Department]
    } else {
        $OUMap["Standard Users"]
    }

    # Check if user already exists
    if (Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction SilentlyContinue) {
        Write-Log "SKIP: User '$Username' already exists." "WARN"
        $SkippedCount++
        continue
    }

    try {
        # Create the user
        New-ADUser `
            -Name              $FullName `
            -GivenName         $FirstName `
            -Surname           $LastName `
            -SamAccountName    $Username `
            -UserPrincipalName $UPN `
            -Path              $TargetOU `
            -Department        $Department `
            -Title             $Title `
            -Company           "CyberKraft Corp" `
            -AccountPassword   $SecurePassword `
            -ChangePasswordAtLogon $true `
            -Enabled           $true `
            -Description       "Created by CyberKraft Lab 01 script on $(Get-Date -Format 'yyyy-MM-dd')"

        Write-Log "CREATED: $Username ($FullName) | Dept: $Department | OU: $TargetOU"
        $CreatedCount++

        # Add to security group if mapped
        if ($GroupMap.ContainsKey($Department)) {
            Add-ADGroupMember -Identity $GroupMap[$Department] -Members $Username
            Write-Log "  -> Added to group: $($GroupMap[$Department])"
        }

    } catch {
        Write-Log "ERROR creating user '$Username': $($_.Exception.Message)" "ERROR"
        $ErrorCount++
    }
}

# ---- Summary ----
Write-Log "=== Bulk User Creation Complete ==="
Write-Log "Total Processed : $TotalUsers"
Write-Log "Created         : $CreatedCount"
Write-Log "Skipped (exist) : $SkippedCount"
Write-Log "Errors          : $ErrorCount"
Write-Log "Log saved to    : $LogFile"

# ---- Final Verification ----
Write-Log "--- Domain User Count Verification ---"
$AllUsers = (Get-ADUser -Filter * -SearchBase "OU=_CYBERKRAFT_USERS,$DomainDN").Count
Write-Log "Total users in _CYBERKRAFT_USERS OU: $AllUsers"

# ---- Export User Report ----
$ReportPath = "C:\Scripts\Logs\UserReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
Get-ADUser -Filter * -SearchBase "OU=_CYBERKRAFT_USERS,$DomainDN" `
    -Properties Department, Title, Created, DistinguishedName |
    Select-Object Name, SamAccountName, Department, Title, Created, DistinguishedName |
    Export-Csv -Path $ReportPath -NoTypeInformation

Write-Log "User report exported to: $ReportPath"
