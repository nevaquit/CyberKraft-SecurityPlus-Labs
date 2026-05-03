# ITSM Incident Lifecycle — CyberKraft Lab 04

> ServiceNow ITSM aligned to ITIL v4 and NIST SP 800-61

---

## Incident Management Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    INCIDENT MANAGEMENT LIFECYCLE                        │
│                    CyberKraft Lab 04 — ServiceNow                       │
└─────────────────────────────────────────────────────────────────────────┘

  DETECTION                TRIAGE                INVESTIGATION           RESOLUTION
     │                       │                        │                      │
     ▼                       ▼                        ▼                      ▼
┌─────────┐           ┌─────────────┐         ┌──────────────┐       ┌──────────────┐
│ Splunk  │──Alert──► │  Incident   │──P1-P4─►│  Assign to   │──────►│  Resolve &   │
│  Alert  │           │  Created    │         │  SOC Analyst │       │  Document    │
└─────────┘           │ (INC#####)  │         └──────────────┘       └──────────────┘
                      └─────────────┘                │                      │
  DETECTION                                    ┌─────┴──────┐         ┌─────┴──────┐
     │                                         │ Contain &  │         │  Close     │
     ▼                                         │ Investigate│         │  Incident  │
┌─────────┐                                    └────────────┘         └────────────┘
│ User    │──Report─►                                │                      │
│ Report  │                                    ┌─────┴──────┐               │
└─────────┘                                    │ Eradicate  │               ▼
                                               │ & Recover  │        ┌──────────────┐
  DETECTION                                    └────────────┘        │  Post-       │
     │                                                               │  Incident    │
     ▼                                                               │  Review      │
┌─────────┐                                                          └──────────────┘
│ Monitor │──Alert──►                                                       │
│  Tool   │                                                                 ▼
└─────────┘                                                         ┌──────────────┐
                                                                    │  Problem     │
                                                                    │  Record      │
                                                                    │  (if needed) │
                                                                    └──────────────┘
```

---

## Priority Matrix

```
                    URGENCY
                 High    Medium    Low
              ┌────────┬────────┬────────┐
         High │  P1    │  P2    │  P3    │
IMPACT        ├────────┼────────┼────────┤
       Medium │  P2    │  P3    │  P4    │
              ├────────┼────────┼────────┤
          Low │  P3    │  P4    │  P4    │
              └────────┴────────┴────────┘

P1 = Critical  → Response: 15 min  | Resolution: 4 hours
P2 = High      → Response: 1 hour  | Resolution: 8 hours
P3 = Moderate  → Response: 4 hours | Resolution: 24 hours
P4 = Low       → Response: 8 hours | Resolution: 72 hours
```

---

## NIST IR Framework ↔ ServiceNow Mapping

```
NIST Phase              ServiceNow Record          Actions
─────────────────────────────────────────────────────────────────────
1. PREPARATION     →    SLA Definitions            Configure P1-P4 SLAs
                        Assignment Groups           Create SOC team groups
                        Runbooks                    Document IR procedures

2. DETECTION &     →    Incident Created            Splunk alert → INC#####
   ANALYSIS             Work Notes                  Document initial findings
                        Priority Set                Assign P1-P4 based on matrix

3. CONTAINMENT     →    Work Notes                  Document containment steps
                        Tasks                       Assign isolation tasks
                        Change Request              Emergency change if needed

4. ERADICATION     →    Work Notes                  Document removal steps
                        Related Records             Link to vulnerability findings

5. RECOVERY        →    Work Notes                  Document recovery steps
                        Incident Resolved           Set state to Resolved
                        Resolution Notes            Document final resolution

6. POST-INCIDENT   →    Problem Record              Create PRB##### if recurring
   ACTIVITY             Lessons Learned             Document in Problem record
                        Known Error                 Create KEDB entry
```

---

## Change Management Lifecycle

```
┌──────────────────────────────────────────────────────────────────────┐
│                    CHANGE MANAGEMENT LIFECYCLE                       │
└──────────────────────────────────────────────────────────────────────┘

  REQUEST              ASSESSMENT            APPROVAL              IMPLEMENTATION
     │                     │                    │                       │
     ▼                     ▼                    ▼                       ▼
┌─────────┐         ┌───────────┐        ┌──────────┐           ┌──────────────┐
│ Change  │─────────│ Risk &    │────────│   CAB    │───────────│  Implement   │
│ Request │         │ Impact    │        │ Approval │           │  & Verify    │
│ Created │         │ Assessment│        │          │           │              │
└─────────┘         └───────────┘        └──────────┘           └──────────────┘
                                              │                        │
                                         ┌────┴────┐            ┌──────┴──────┐
                                         │Approved?│            │  Post-Impl  │
                                         └────┬────┘            │  Review     │
                                         Yes  │  No             └─────────────┘
                                              │    └──► Reject/Rework
                                              ▼
                                        ┌──────────┐
                                        │ Schedule │
                                        │ Maint.   │
                                        │ Window   │
                                        └──────────┘

Change Types:
  Standard  → Pre-approved, low risk, routine (e.g., password reset)
  Normal    → Full CAB review required (e.g., patch deployment)
  Emergency → Expedited approval for critical security patches
```

---

## SLA Breach Escalation

```
SLA Timeline (P2 — High Priority)

  0:00 ─── Incident Created
  0:15 ─── Response SLA: Analyst must acknowledge
  1:00 ─── ⚠️ Response SLA BREACH → Escalate to Team Lead
  4:00 ─── Investigation checkpoint
  8:00 ─── Resolution SLA: Incident must be resolved
  8:01 ─── ⚠️ Resolution SLA BREACH → Escalate to Manager
```

---

*CyberKraft Security+ Lab 04 | Henry Jenkins | ServiceNow PDI*
