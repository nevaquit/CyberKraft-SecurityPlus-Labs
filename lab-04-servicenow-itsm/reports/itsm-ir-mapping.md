# Lab 04 ITSM Report — Incident Response Mapping

**Lab:** CyberKraft Security+ Lab 04
**Title:** ServiceNow ITSM — Incident & Change Management
**Analyst:** Henry Jenkins
**Date:** May 3, 2026

---

## Incidents Managed

| Record | Title | Priority | Status | MTTR |
|--------|-------|----------|--------|------|
| INC0010001 | Brute force attack — alice.johnson | P2 High | Resolved | 48 min |
| INC0010002 | Unauthorized USB device — ACCT-PC-003 | P2 High | Resolved | 35 min |
| INC0010003 | Phishing email with malicious attachment | P1 Critical | Resolved | 22 min |

## Change Requests

| Record | Title | Type | Status | Risk |
|--------|-------|------|--------|------|
| CHG0020001 | Deploy KB5031539 (CVE-2023-44487) | Normal | Implemented | Moderate |

## Problem Records

| Record | Title | Status | Root Cause |
|--------|-------|--------|------------|
| PRB0030001 | Recurring account lockouts | Root Cause Identified | Stale cached credentials |

---

## NIST IR Framework Compliance

All three incidents were handled in full compliance with NIST SP 800-61 Rev 2:

| Phase | INC0010001 | INC0010002 | INC0010003 |
|-------|-----------|-----------|-----------|
| Detection | Splunk alert | Event log | User report |
| Analysis | 8 minutes | 5 minutes | 3 minutes |
| Containment | WKSTN isolated | USB removed | Email quarantined |
| Eradication | Script removed | Policy enforced | Attachment deleted |
| Recovery | Account unlocked | Normal ops | Normal ops |
| Post-Incident | Problem record | GPO review | Awareness training |

---

## SLA Performance

| Priority | Target Response | Actual Response | Met? |
|----------|----------------|-----------------|------|
| P1 (INC0010003) | 15 minutes | 8 minutes | ✅ |
| P2 (INC0010001) | 1 hour | 12 minutes | ✅ |
| P2 (INC0010002) | 1 hour | 9 minutes | ✅ |

---

*Report by Henry Jenkins | CyberKraft Lab 04 | ServiceNow PDI*
