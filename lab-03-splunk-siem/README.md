# Lab 03 — Splunk SIEM & Log Analysis

**SY0-701 Domains:** 4.1 Monitoring & Detection · 4.3 Incident Response · 2.2 Threat Intelligence

---

## Why This Lab Matters

Splunk is the most widely deployed SIEM platform in enterprise environments. Proficiency with Splunk's Search Processing Language (SPL), dashboard creation, and alert configuration is one of the most in-demand skills for SOC Analyst, Tier 1/2 positions. This lab demonstrates end-to-end SIEM operations: ingesting logs, writing detection queries, building dashboards, and responding to alerts.

### Cloud Architecture Integration
In our Azure cloud architecture (**Lab 06**), Splunk acts as the centralized logging and monitoring hub. By deploying Splunk on an Azure VM and configuring Network Security Groups (NSGs) to allow ingestion traffic (Port 9997) while restricting web access (Port 8000) to trusted IPs, we apply cloud engineering principles of microsegmentation and centralized visibility. Splunk can also be integrated with Azure Monitor and Azure AD logs for comprehensive cloud posture visibility.

---

## Environment

| Component | Details |
|-----------|---------|
| **Platform** | Microsoft Azure — HenryVM (South Africa North) |
| **OS** | Windows Server 2022 |
| **Splunk Version** | Splunk Enterprise 9.x (Free Trial / Developer License) |
| **Splunk Port** | 8000 (Web UI), 9997 (Forwarder) |
| **Log Sources** | Windows Security Event Log, Sysmon, IIS, PowerShell |
| **Index** | `main`, `windows`, `sysmon` |

---

## Objectives

1. Install Splunk Enterprise on HenryVM
2. Configure the Splunk Universal Forwarder to collect Windows Event Logs
3. Install the Splunk Add-on for Microsoft Windows
4. Ingest Security, System, and Application event logs
5. Write SPL queries to detect security events
6. Build a Security Operations Dashboard
7. Configure real-time alerts for critical events
8. Simulate and detect a brute-force attack

---

## Step-by-Step Execution

### Phase 1: Splunk Enterprise Installation

**Download Splunk Enterprise:**

```powershell
$SplunkURL = "https://download.splunk.com/products/splunk/releases/9.3.0/windows/splunk-9.3.0-51ccf43db5bd-x64-release.msi"
$InstallerPath = "C:\Temp\splunk-installer.msi"
Invoke-WebRequest -Uri $SplunkURL -OutFile $InstallerPath

# Silent install
msiexec.exe /i $InstallerPath SPLUNK_HOME="C:\Program Files\Splunk" `
    SPLUNKD_PORT="8089" `
    LAUNCHSPLUNK=1 `
    SERVICESTARTTYPE=auto `
    AGREETOLICENSE=yes `
    /quiet
```

**Start Splunk and set admin password:**

```powershell
cd "C:\Program Files\Splunk\bin"
.\splunk.exe start --accept-license
.\splunk.exe enable boot-start
.\splunk.exe edit user admin -password "CyberKraft2024!" -auth admin:changeme
```

**Access Splunk Web UI:**
- URL: `http://localhost:8000`
- Username: `admin`
- Password: `CyberKraft2024!`

---

### Phase 2: Configure Data Inputs

**Enable Windows Event Log collection via Splunk Web:**

Navigate to: `Settings > Data Inputs > Local Event Log Monitoring`

Add the following event log channels:

| Event Log Channel | Index | Why It Matters |
|------------------|-------|----------------|
| Security | windows | Authentication, privilege use, account management |
| System | windows | Service failures, driver issues |
| Application | windows | Application errors, crashes |
| Microsoft-Windows-Sysmon/Operational | sysmon | Process creation, network connections, file changes |
| Microsoft-Windows-PowerShell/Operational | windows | PowerShell command execution |
| Microsoft-Windows-TaskScheduler/Operational | windows | Scheduled task creation (persistence) |

**Create indexes:**

```bash
# In Splunk CLI
splunk add index windows -maxTotalDataSizeMB 5000
splunk add index sysmon -maxTotalDataSizeMB 5000
splunk restart
```

**Configure inputs.conf for Windows Event Logs:**

```ini
# File: C:\Program Files\Splunk\etc\system\local\inputs.conf

[WinEventLog://Security]
disabled = 0
index = windows
start_from = oldest
current_only = 0
evt_resolve_ad_obj = 1

[WinEventLog://System]
disabled = 0
index = windows

[WinEventLog://Application]
disabled = 0
index = windows

[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = 0
index = sysmon
renderXml = true

[WinEventLog://Microsoft-Windows-PowerShell/Operational]
disabled = 0
index = windows
```

---

### Phase 3: Install Splunk Add-on for Windows

1. Navigate to `Apps > Find More Apps`
2. Search for "Splunk Add-on for Microsoft Windows"
3. Install and configure field extractions
4. Restart Splunk

This add-on provides:
- Pre-built field extractions for Windows Event IDs
- CIM (Common Information Model) compliance
- Lookup tables for event descriptions

---

### Phase 4: SPL Detection Queries

See the full SPL query library at [`spl-queries/`](./spl-queries/).

#### Query 1 — Failed Login Attempts (Brute Force Detection)

```spl
index=windows EventCode=4625
| stats count by src_ip, user, host
| where count > 5
| sort -count
| rename count as "Failed_Attempts"
| table src_ip, user, host, Failed_Attempts
```

**Purpose:** Detects accounts with more than 5 failed login attempts — a brute-force indicator.

---

#### Query 2 — Successful Logins After Multiple Failures

```spl
index=windows EventCode=4625
| stats count as failures by user, src_ip
| where failures > 5
| join user [
    search index=windows EventCode=4624
    | stats count as successes by user, src_ip
]
| table user, src_ip, failures, successes
| where successes > 0
```

**Purpose:** Detects successful login following multiple failures — possible successful brute force.

---

#### Query 3 — Account Lockouts

```spl
index=windows EventCode=4740
| table _time, user, src, host, Subject_Account_Name
| sort -_time
```

**Purpose:** Shows all account lockout events with source IP and timestamp.

---

#### Query 4 — New User Account Creation

```spl
index=windows EventCode=4720
| table _time, user, Target_Account_Name, Subject_Account_Name, host
| sort -_time
```

**Purpose:** Detects new user account creation — potential unauthorized account creation.

---

#### Query 5 — Privileged Group Membership Changes

```spl
index=windows (EventCode=4728 OR EventCode=4732 OR EventCode=4756)
| eval GroupChange=case(
    EventCode=4728, "Added to Global Security Group",
    EventCode=4732, "Added to Local Security Group",
    EventCode=4756, "Added to Universal Security Group"
)
| table _time, user, Target_Account_Name, Group_Name, GroupChange, host
| sort -_time
```

**Purpose:** Detects privilege escalation via group membership changes.

---

#### Query 6 — PowerShell Script Execution

```spl
index=windows source="WinEventLog:Microsoft-Windows-PowerShell/Operational"
EventCode=4104
| eval ScriptLength=len(ScriptBlockText)
| where ScriptLength > 100
| table _time, host, user, ScriptBlockText
| sort -_time
```

**Purpose:** Detects PowerShell script block execution — common in fileless malware attacks.

---

#### Query 7 — Suspicious Process Creation (Sysmon)

```spl
index=sysmon EventCode=1
| where (ParentImage LIKE "%cmd.exe%" OR ParentImage LIKE "%powershell.exe%")
    AND (Image LIKE "%net.exe%" OR Image LIKE "%whoami.exe%" OR Image LIKE "%ipconfig.exe%")
| table _time, host, user, Image, CommandLine, ParentImage, ParentCommandLine
| sort -_time
```

**Purpose:** Detects reconnaissance commands spawned from cmd/PowerShell — post-exploitation indicator.

---

#### Query 8 — Network Connection to Unusual Ports (Sysmon)

```spl
index=sysmon EventCode=3
| where NOT (DestinationPort=80 OR DestinationPort=443 OR DestinationPort=53)
| stats count by DestinationIp, DestinationPort, Image, host
| where count > 5
| sort -count
```

**Purpose:** Detects processes making connections to unusual ports — possible C2 communication.

---

#### Query 9 — Security Event Volume Over Time

```spl
index=windows
| timechart span=1h count by EventCode
| eval EventCode=case(
    EventCode=4624, "Successful Logon",
    EventCode=4625, "Failed Logon",
    EventCode=4648, "Explicit Credential Logon",
    EventCode=4720, "User Account Created",
    EventCode=4740, "Account Locked Out",
    true(), "Other"
)
```

**Purpose:** Visualize security event trends over time — baseline and anomaly detection.

---

#### Query 10 — Top 10 Event IDs

```spl
index=windows
| stats count by EventCode
| sort -count
| head 10
| lookup windows_eventcodes EventCode OUTPUT EventDescription
| table EventCode, EventDescription, count
```

**Purpose:** Identify the most common event types — helps prioritize investigation focus.

---

### Phase 5: Security Operations Dashboard

**Dashboard: CyberKraft SOC Overview**

The dashboard was created with the following panels:

| Panel | SPL Query | Visualization |
|-------|-----------|---------------|
| Failed Logins (Last 24h) | `EventCode=4625 \| timechart count` | Line chart |
| Top Failed Login Users | `EventCode=4625 \| top user` | Bar chart |
| Account Lockouts | `EventCode=4740 \| table _time, user` | Table |
| New Accounts Created | `EventCode=4720 \| table _time, user` | Table |
| Privileged Group Changes | `EventCode=4728 OR 4732 \| table` | Table |
| Event Volume Heatmap | `\| timechart span=1h count` | Heatmap |
| Top Source IPs | `EventCode=4625 \| top src_ip` | Pie chart |
| PowerShell Executions | `EventCode=4104 \| table` | Table |

**Dashboard XML export:** See [`dashboards/soc-overview-dashboard.xml`](./dashboards/soc-overview-dashboard.xml)

---

### Phase 6: Alert Configuration

**Alert 1 — Brute Force Attack**

| Setting | Value |
|---------|-------|
| Name | CK-Alert-BruteForce |
| Search | `index=windows EventCode=4625 \| stats count by src_ip, user \| where count > 10` |
| Schedule | Real-time |
| Trigger | Per result |
| Action | Email + Log to index |
| Severity | High |

**Alert 2 — Account Lockout**

| Setting | Value |
|---------|-------|
| Name | CK-Alert-AccountLockout |
| Search | `index=windows EventCode=4740` |
| Schedule | Real-time |
| Trigger | Per result |
| Action | Email + Log to index |
| Severity | Medium |

**Alert 3 — New Admin Account**

| Setting | Value |
|---------|-------|
| Name | CK-Alert-NewAdminAccount |
| Search | `index=windows (EventCode=4728 OR EventCode=4732) Group_Name="Domain Admins"` |
| Schedule | Real-time |
| Trigger | Per result |
| Action | Email + Log to index |
| Severity | Critical |

---

### Phase 7: Brute Force Attack Simulation & Detection

**Simulate brute force from PowerShell:**

```powershell
# WARNING: Only run in lab environment — this will trigger lockout
$Target = "HenryVM"
$Username = "alice.johnson"
$Passwords = @("Password1", "Password2", "Password3", "Password4", 
               "Password5", "Password6", "Password7", "Password8")

foreach ($Password in $Passwords) {
    $Credential = New-Object System.Management.Automation.PSCredential(
        "$Target\$Username",
        (ConvertTo-SecureString $Password -AsPlainText -Force)
    )
    try {
        $Session = New-PSSession -ComputerName $Target -Credential $Credential -ErrorAction Stop
        Write-Host "SUCCESS: Password found: $Password"
        Remove-PSSession $Session
        break
    } catch {
        Write-Host "FAILED: $Password"
    }
}
```

**Detection in Splunk:**

```spl
index=windows EventCode=4625
| stats count as failed_attempts, 
        values(IpAddress) as source_ips,
        earliest(_time) as first_attempt,
        latest(_time) as last_attempt
  by TargetUserName
| where failed_attempts > 5
| eval duration_seconds = last_attempt - first_attempt
| eval attempts_per_minute = round(failed_attempts / (duration_seconds / 60), 2)
| convert ctime(first_attempt) ctime(last_attempt)
| sort -failed_attempts
```

**Expected Result:** Alert fires when `alice.johnson` accumulates 6+ failed logins. Event ID 4740 (lockout) appears after the 5th failure per the GPO configured in Lab 01.

---

## Evidence & Findings

### Screenshot Inventory

| File | Description |
|------|-------------|
| `screenshots/01-splunk-home.png` | Splunk Enterprise home page |
| `screenshots/02-data-inputs-configured.png` | Windows Event Log inputs configured |
| `screenshots/03-index-summary.png` | Index statistics showing ingested events |
| `screenshots/04-spl-failed-logins.png` | Failed login query results |
| `screenshots/05-spl-brute-force.png` | Brute force detection query results |
| `screenshots/06-spl-account-lockout.png` | Account lockout events |
| `screenshots/07-spl-new-user-creation.png` | New user account creation events |
| `screenshots/08-dashboard-soc-overview.png` | Full SOC dashboard view |
| `screenshots/09-alert-configured.png` | Brute force alert configuration |
| `screenshots/10-alert-triggered.png` | Alert firing after simulated attack |
| `screenshots/11-sysmon-process-creation.png` | Sysmon process creation events |
| `screenshots/12-powershell-detection.png` | PowerShell script block logging |

---

## Security+ Domain Connections

| Action Performed | SY0-701 Domain | Concept |
|-----------------|----------------|---------|
| Log ingestion and indexing | 4.1 Monitoring & Detection | Log management, SIEM |
| Brute force detection query | 4.1 Monitoring & Detection | Anomaly detection, alerting |
| Alert configuration | 4.3 Incident Response | Incident detection, notification |
| Dashboard creation | 4.1 Monitoring & Detection | Security monitoring, visualization |
| Simulated attack detection | 2.2 Threat Intelligence | IOC identification, threat hunting |
| PowerShell logging | 4.1 Monitoring & Detection | Endpoint detection |

---

## Lessons Learned

**SIEM is Only as Good as Its Inputs:** Splunk can only detect what it can see. Enabling Sysmon, PowerShell logging, and Windows Security Event Log collection dramatically increases visibility. Without these sources, entire attack categories are invisible.

**SPL is a Force Multiplier:** A single well-crafted SPL query can scan millions of events in seconds. The brute force detection query that would take hours to review manually runs in under 5 seconds in Splunk.

**Baselining Reduces False Positives:** Understanding normal event volumes (e.g., how many failed logins are typical in a day) is essential before setting alert thresholds. Too sensitive = alert fatigue; too lenient = missed detections.

**Correlation is Key:** The most powerful detections combine multiple event types. Detecting failed logins alone is noisy; detecting failed logins followed by a successful login is a high-confidence indicator of a successful brute force.

---

## References

- [Splunk Documentation](https://docs.splunk.com)
- [Splunk SPL Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference)
- [MITRE ATT&CK: T1110 Brute Force](https://attack.mitre.org/techniques/T1110/)
- [Windows Security Event Log Reference](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)
- [Sysmon Configuration Guide](https://github.com/SwiftOnSecurity/sysmon-config)
- [Splunk Security Essentials App](https://splunkbase.splunk.com/app/3435)
