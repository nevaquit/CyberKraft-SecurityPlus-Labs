# Lab 04 — ServiceNow ITSM: Incident & Change Management

**SY0-701 Domains:** 4.3 Incident Response · 5.3 Risk Management & Compliance · 5.4 Data Privacy

---

## Why This Lab Matters

ServiceNow is the leading IT Service Management (ITSM) platform, used by over 85% of Fortune 500 companies. Understanding ITSM workflows — specifically Incident Management, Change Management, and Problem Management — is essential for security professionals who must document, track, and resolve security incidents in a structured, auditable way. This lab maps directly to the Security+ exam's Incident Response and Governance domains.

### Cloud Architecture Integration
In a cloud-first architecture (**Lab 06**), ITSM platforms like ServiceNow (a SaaS solution) integrate directly with cloud infrastructure (IaaS) and security tools (like Azure Monitor or Splunk). This lab demonstrates how alerts generated from our Azure VM environment are translated into actionable, tracked incidents within a SaaS ITSM platform, ensuring that cloud security events are managed according to ITIL and NIST frameworks.

---

## Environment

| Component | Details |
|-----------|---------|
| **Platform** | ServiceNow Personal Developer Instance (PDI) |
| **Access** | Browser-based (https://developer.servicenow.com) |
| **Instance URL** | `https://<dev-instance>.service-now.com` |
| **ITSM Modules** | Incident Management, Change Management, Problem Management |
| **ITIL Alignment** | ITIL v4 Foundation |

---

## Objectives

1. Provision a ServiceNow Personal Developer Instance (PDI)
2. Create and manage a security incident from detection to closure
3. Document a Change Request for a security patch deployment
4. Link a Problem Record to recurring incidents
5. Configure SLA (Service Level Agreement) definitions
6. Map the full ITSM lifecycle to the NIST Incident Response Framework
7. Generate management reports from ServiceNow

---

## Step-by-Step Execution

### Phase 1: ServiceNow PDI Setup

**Provision a Personal Developer Instance:**

1. Navigate to [https://developer.servicenow.com](https://developer.servicenow.com)
2. Create a free developer account
3. Click **Request Instance** and select the latest release (e.g., Washington DC)
4. Wait for provisioning (typically 5-10 minutes)
5. Note the instance URL: `https://dev<XXXXX>.service-now.com`

**Login credentials:**
- Username: `admin`
- Password: (provided during provisioning)

---

### Phase 2: Incident Management

#### Incident 1 — Brute Force Attack Detection

**Scenario:** The Splunk SIEM (Lab 03) triggered an alert for 15 failed login attempts against `alice.johnson` from IP `10.0.0.5` within 5 minutes. The account was subsequently locked out (Event ID 4740).

**Create Incident Record:**

Navigate to: `Incident > Create New`

| Field | Value |
|-------|-------|
| **Number** | INC0010001 |
| **Caller** | Henry Jenkins (SOC Analyst) |
| **Category** | Security |
| **Subcategory** | Unauthorized Access |
| **Short Description** | Brute force attack detected against alice.johnson — account locked |
| **Description** | Splunk SIEM alert CK-Alert-BruteForce triggered at 14:32 UTC. Source IP 10.0.0.5 generated 15 failed login attempts (Event ID 4625) against user alice.johnson within 5 minutes. Account was automatically locked (Event ID 4740) per GPO policy. Possible credential stuffing or targeted brute force attack. |
| **Impact** | 2 — Medium |
| **Urgency** | 2 — Medium |
| **Priority** | P2 — High |
| **Assignment Group** | Security Operations |
| **Assigned To** | Henry Jenkins |
| **State** | In Progress |
| **Configuration Item** | HenryVM (Azure) |

**Priority Matrix:**

| Impact | Urgency | Priority |
|--------|---------|----------|
| 1 — High | 1 — High | P1 — Critical |
| 1 — High | 2 — Medium | P2 — High |
| 2 — Medium | 1 — High | P2 — High |
| 2 — Medium | 2 — Medium | P3 — Moderate |
| 3 — Low | 3 — Low | P4 — Low |

**Work Notes (Investigation Timeline):**

```
[14:32 UTC] Splunk alert triggered: CK-Alert-BruteForce
[14:33 UTC] Analyst acknowledged alert. Reviewing Event Viewer on HenryVM.
[14:35 UTC] Confirmed 15 failed logins (EventCode 4625) from 10.0.0.5 to alice.johnson
[14:36 UTC] Account lockout confirmed (EventCode 4740)
[14:38 UTC] Source IP 10.0.0.5 identified as internal workstation WKSTN-005
[14:40 UTC] WKSTN-005 isolated from network pending investigation
[14:45 UTC] Malware scan initiated on WKSTN-005 — no malware found
[14:50 UTC] User alice.johnson contacted — confirmed no knowledge of login attempts
[14:55 UTC] Determined cause: automated script left running on WKSTN-005 by previous user
[15:00 UTC] Script removed from WKSTN-005
[15:05 UTC] alice.johnson account unlocked by Help Desk
[15:10 UTC] WKSTN-005 reconnected to network
[15:15 UTC] Monitoring for 24 hours — no further incidents
[15:20 UTC] Incident resolved and closed
```

**Resolution:**

| Field | Value |
|-------|-------|
| **Resolution Code** | Solved (Permanently) |
| **Resolution Notes** | Automated script removed from WKSTN-005. Account unlocked. Root cause: legacy test script with hardcoded credentials left running by previous user. No malicious activity confirmed. |
| **Close Code** | Solved (Permanently) |
| **Resolved By** | Henry Jenkins |
| **Resolved At** | 15:20 UTC |

---

#### Incident 2 — Unauthorized USB Device

**Scenario:** Windows Security Event Log shows a USB storage device was connected to a workstation in the Accounting OU, bypassing the USB disable GPO (which was not yet applied to that OU).

| Field | Value |
|-------|-------|
| **Number** | INC0010002 |
| **Category** | Security |
| **Subcategory** | Policy Violation |
| **Short Description** | Unauthorized USB device connected on ACCT-PC-003 |
| **Impact** | 2 — Medium |
| **Urgency** | 1 — High |
| **Priority** | P2 — High |
| **State** | Resolved |

---

#### Incident 3 — Phishing Email Reported

**Scenario:** User reports receiving a suspicious email with a malicious attachment claiming to be an invoice.

| Field | Value |
|-------|-------|
| **Number** | INC0010003 |
| **Category** | Security |
| **Subcategory** | Phishing |
| **Short Description** | Phishing email with malicious attachment reported by user |
| **Impact** | 1 — High |
| **Urgency** | 1 — High |
| **Priority** | P1 — Critical |
| **State** | Resolved |

---

### Phase 3: Change Management

**Change Request — Deploy Security Patch KB5031539**

**Scenario:** Microsoft released a critical security patch (KB5031539) addressing a remote code execution vulnerability (CVE-2023-44487). The patch must be deployed to all domain-joined machines.

Navigate to: `Change > Create New`

| Field | Value |
|-------|-------|
| **Number** | CHG0020001 |
| **Type** | Normal |
| **Category** | Software |
| **Short Description** | Deploy Windows Security Patch KB5031539 (CVE-2023-44487) |
| **Description** | Critical security patch addressing HTTP/2 Rapid Reset vulnerability (CVE-2023-44487, CVSS 7.5). Patch must be deployed to all 50 domain-joined workstations and 3 servers within the maintenance window. |
| **Risk** | Moderate |
| **Impact** | 2 — Medium |
| **Priority** | 2 — High |
| **Requested By** | Henry Jenkins |
| **Assignment Group** | IT Operations |
| **Planned Start Date** | Saturday 02:00 UTC |
| **Planned End Date** | Saturday 06:00 UTC |
| **State** | Approved |

**Implementation Plan:**

```
1. Pre-change backup: Create VM snapshot of HenryVM (30 min)
2. Test deployment: Apply patch to 1 test workstation (30 min)
3. Verify test workstation: Check services, applications, event logs (30 min)
4. Production deployment: Deploy to all workstations via WSUS/SCCM (120 min)
5. Server deployment: Apply to servers with individual verification (60 min)
6. Post-change verification: Run vulnerability scan to confirm patch applied (30 min)
7. Rollback plan: Restore from VM snapshot if critical failure
```

**Risk Assessment:**

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Patch causes application failure | Low | High | Test on isolated workstation first |
| Reboot causes service downtime | Medium | Medium | Schedule during maintenance window |
| Patch fails to install | Low | Medium | WSUS retry mechanism |
| Rollback required | Very Low | High | VM snapshot pre-change |

**Change Advisory Board (CAB) Approval:**

| Approver | Role | Decision | Date |
|----------|------|----------|------|
| Henry Jenkins | SOC Analyst | Approved | 2024-01-15 |
| IT Manager | IT Operations | Approved | 2024-01-15 |
| CISO | Security | Approved | 2024-01-15 |

---

### Phase 4: Problem Management

**Problem Record — Recurring Account Lockouts**

**Scenario:** Over the past 30 days, 8 incidents have been raised for account lockouts across the domain. A Problem Record is created to identify the root cause.

Navigate to: `Problem > Create New`

| Field | Value |
|-------|-------|
| **Number** | PRB0030001 |
| **Short Description** | Recurring account lockouts across domain — root cause investigation |
| **Description** | 8 incidents in 30 days involving account lockouts (INC0010001, INC0010004-INC0010010). Pattern analysis suggests multiple workstations have stale cached credentials causing automatic lockouts. |
| **Category** | Security |
| **Priority** | 2 — High |
| **State** | Root Cause Analysis |
| **Assignment Group** | Security Operations |

**Root Cause Analysis (RCA):**

| Step | Finding |
|------|---------|
| 1. Incident correlation | 8 lockout incidents linked to Problem |
| 2. Pattern analysis | All lockouts occur between 08:00-09:00 (morning login time) |
| 3. Source identification | Lockouts originate from workstations, not servers |
| 4. Root cause | Stale cached credentials on workstations after password changes |
| 5. Contributing factor | GPO "Interactive logon: Number of previous logons to cache" set too high |

**Known Error Record:**

| Field | Value |
|-------|-------|
| **Known Error** | Yes |
| **Workaround** | Help Desk to clear cached credentials on affected workstation |
| **Permanent Fix** | Reduce cached logon count GPO from 10 to 2; implement credential refresh notification |

---

### Phase 5: SLA Configuration

**SLA Definition — Security Incident Response**

Navigate to: `Service Level Management > SLA Definitions > New`

| Priority | Response Time | Resolution Time |
|----------|--------------|-----------------|
| P1 — Critical | 15 minutes | 4 hours |
| P2 — High | 1 hour | 8 hours |
| P3 — Moderate | 4 hours | 24 hours |
| P4 — Low | 8 hours | 72 hours |

---

### Phase 6: NIST IR Framework Mapping

| NIST Phase | NIST Activity | ServiceNow Record | Lab Action |
|-----------|---------------|-------------------|------------|
| **Preparation** | Establish IR capability | SLA definitions | Configured P1-P4 SLAs |
| **Detection & Analysis** | Identify incident | INC0010001 created | Splunk alert → Incident |
| **Containment** | Isolate affected systems | Work notes in INC | WKSTN-005 isolated |
| **Eradication** | Remove threat | Resolution notes | Script removed |
| **Recovery** | Restore operations | Incident resolved | Account unlocked, system reconnected |
| **Post-Incident** | Lessons learned | Problem record | PRB0030001 created |

---

## Evidence & Findings

### Screenshot Inventory

| File | Description |
|------|-------------|
| `screenshots/01-incident-list.png` | ServiceNow incident queue |
| `screenshots/02-inc0010001-details.png` | Brute force incident record |
| `screenshots/03-inc0010001-work-notes.png` | Investigation timeline work notes |
| `screenshots/04-inc0010001-resolved.png` | Incident resolution details |
| `screenshots/05-change-request.png` | Patch deployment change request |
| `screenshots/06-change-cab-approval.png` | CAB approval workflow |
| `screenshots/07-problem-record.png` | Recurring lockout problem record |
| `screenshots/08-sla-definitions.png` | SLA configuration |
| `screenshots/09-incident-dashboard.png` | Incident management dashboard |
| `screenshots/10-reports-mttr.png` | Mean Time to Resolve report |

---

## Security+ Domain Connections

| Action Performed | SY0-701 Domain | Concept |
|-----------------|----------------|---------|
| Incident creation and lifecycle | 4.3 Incident Response | IR procedures, documentation |
| NIST framework mapping | 4.3 Incident Response | Preparation, detection, containment |
| Change management process | 5.3 Risk Management | Change control, risk assessment |
| SLA configuration | 5.3 Risk Management | Service levels, compliance |
| Problem management RCA | 4.3 Incident Response | Root cause analysis, lessons learned |
| Audit trail via work notes | 5.4 Data Privacy | Evidence preservation, chain of custody |

---

## Lessons Learned

**Documentation is Evidence:** Every work note, resolution note, and timestamp in ServiceNow creates an auditable trail. In a real security incident, this documentation is critical for legal proceedings, regulatory compliance, and post-incident review.

**ITSM Enforces Process Discipline:** Without a structured ITSM tool, incident response becomes ad-hoc and inconsistent. ServiceNow enforces the ITIL process: every incident has an owner, a priority, a timeline, and a resolution — ensuring nothing falls through the cracks.

**Change Management Prevents Incidents:** The Change Request process for the security patch (CHG0020001) required a test deployment, rollback plan, and CAB approval. This structured approach prevents the "patch broke production" scenario that creates new incidents.

**Problem Management Closes the Loop:** Without Problem Management, the same incident (account lockouts) would keep recurring. The Problem Record forced a root cause investigation that led to a permanent fix — reducing future incident volume.

---

## References

- [ServiceNow Documentation](https://docs.servicenow.com)
- [ITIL v4 Foundation](https://www.axelos.com/certifications/itil-service-management)
- [NIST SP 800-61: Computer Security Incident Handling Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
- [ServiceNow Developer Program](https://developer.servicenow.com)
- [MITRE ATT&CK: T1110 Brute Force](https://attack.mitre.org/techniques/T1110/)
