# Lab 03 Splunk SIEM — Incident Detection Report

**Lab:** CyberKraft Security+ Lab 03
**Title:** Splunk SIEM & Log Analysis
**Analyst:** Henry Jenkins
**Date:** May 3, 2026
**Platform:** Azure HenryVM (South Africa North)

---

## SIEM Configuration Summary

| Component | Details |
|-----------|---------|
| Splunk Version | Enterprise 9.3.0 |
| Indexes Created | windows, sysmon |
| Log Sources | Security, System, Application, Sysmon, PowerShell |
| Total Events Ingested | ~125,000 (first 24 hours) |
| Alerts Configured | 3 (BruteForce, Lockout, NewAdminAccount) |
| Dashboard Panels | 8 |

---

## Brute Force Attack Simulation Results

### Attack Details
- **Target User:** alice.johnson
- **Attack Type:** Password spray / brute force
- **Source:** PowerShell script on HenryVM
- **Passwords Tried:** 8
- **Duration:** ~45 seconds

### Detection Timeline

| Time | Event | Event ID | Detection |
|------|-------|----------|-----------|
| T+0:00 | First failed login | 4625 | Logged |
| T+0:05 | 5th failed login | 4625 | Alert threshold approaching |
| T+0:06 | Account locked out | 4740 | **Alert: CK-Alert-AccountLockout FIRED** |
| T+0:10 | 6th failed login | 4625 | **Alert: CK-Alert-BruteForce FIRED** |
| T+0:15 | Analyst acknowledges | N/A | Incident created in ServiceNow |

### SPL Detection Query Results

```
index=windows EventCode=4625
| stats count as Failed_Attempts by TargetUserName, IpAddress
| where Failed_Attempts >= 5

Results:
TargetUserName  IpAddress    Failed_Attempts
alice.johnson   10.0.0.4     8
```

---

## Top Security Events (Last 24 Hours)

| Event ID | Description | Count |
|----------|-------------|-------|
| 4624 | Successful Logon | 847 |
| 4625 | Failed Logon | 23 |
| 4634 | Logoff | 712 |
| 4720 | User Account Created | 50 |
| 4728 | Added to Global Group | 3 |
| 4740 | Account Locked Out | 2 |

---

## Alert Performance

| Alert | Trigger Count | True Positives | False Positives | Accuracy |
|-------|--------------|----------------|-----------------|----------|
| CK-Alert-BruteForce | 1 | 1 | 0 | 100% |
| CK-Alert-AccountLockout | 2 | 2 | 0 | 100% |
| CK-Alert-NewAdminAccount | 0 | N/A | N/A | N/A |

---

## Recommendations

1. **Tune alert thresholds** based on 30-day baseline data
2. **Add Sysmon** to all domain-joined workstations for process-level visibility
3. **Enable PowerShell script block logging** via GPO (already configured in Lab 01)
4. **Integrate with ServiceNow** for automatic incident creation on alert trigger
5. **Add threat intelligence feeds** (AlienVault OTX, Abuse.ch) for IOC enrichment

---

*Report by Henry Jenkins | CyberKraft Lab 03 | Azure HenryVM*
