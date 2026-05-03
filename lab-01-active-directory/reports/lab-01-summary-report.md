# Lab 01 Summary Report — Active Directory

**Lab:** CyberKraft Security+ Lab 01
**Title:** Active Directory — User, GPO & Security Policy Management
**Analyst:** Henry Jenkins
**Date:** May 3, 2026
**Platform:** Azure HenryVM (South Africa North)

---

## Completion Status

| Task | Status | Notes |
|------|--------|-------|
| Windows Server 2022 domain controller promotion | ✅ Complete | Domain: cyberkraft.local |
| OU structure created (4 top-level, 6 sub-OUs) | ✅ Complete | Matches enterprise design |
| 50 user accounts created via PowerShell | ✅ Complete | All departments covered |
| RBAC security groups created and populated | ✅ Complete | 3 groups, correct membership |
| Password Policy GPO applied | ✅ Complete | 12-char min, 90-day max |
| Audit Logging GPO applied | ✅ Complete | Success+Failure for key categories |
| Screensaver Lock GPO applied | ✅ Complete | 10-minute timeout |
| USB Storage Disable GPO applied | ✅ Complete | Blocks removable storage |
| Windows Firewall GPO applied | ✅ Complete | All profiles enabled |
| Windows 10 client domain-joined | ✅ Complete | Verified via nltest |
| Event Viewer audit events verified | ✅ Complete | 4624, 4625 events confirmed |
| GPResult report generated | ✅ Complete | All 5 GPOs applied |

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Domain name | cyberkraft.local |
| Total users created | 50 |
| OUs created | 10 |
| Security groups created | 3 |
| GPOs created and linked | 5 |
| Domain-joined clients | 1 |
| Script execution time | < 60 seconds |

---

## Security Posture Improvements

Before this lab, the server was a standalone Windows Server with no domain, no password policy, and no audit logging. After completing Lab 01:

- All users must have 12+ character passwords with complexity
- Accounts lock after 5 failed attempts (brute-force protection)
- All logon events are audited (feeds into Splunk in Lab 03)
- USB storage is blocked (data exfiltration prevention)
- Screensaver locks after 10 minutes (physical security)
- Windows Firewall is enforced on all profiles

---

## SY0-701 Objectives Demonstrated

- **2.4** — Identity and Access Management: OU design, RBAC groups, least privilege
- **3.1** — Security Architecture: Domain hierarchy, defense-in-depth
- **4.6** — Hardening: Password policy, account lockout, firewall, USB control

---

*Report by Henry Jenkins | CyberKraft Lab 01 | Azure HenryVM*
