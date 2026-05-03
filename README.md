# CyberKraft Security+ SY0-701 Lab Portfolio

> **CyberKraft Training | CompTIA Security+ Bootcamp**
> Hands-on lab exercises mapped to SY0-701 exam domains, executed on Microsoft Azure (HenryVM — South Africa North region).

---

## Overview

This repository documents six comprehensive, hands-on security labs aligned to the CompTIA Security+ SY0-701 certification exam. Each lab was performed on an Azure Virtual Machine (**HenryVM**, Resource Group: `HENRYVM_GROUP`, Location: `South Africa North`) and produces real, portfolio-grade artifacts that demonstrate hands-on competency to hiring managers.

| Lab | Title | SY0-701 Domains | Status |
|-----|-------|-----------------|--------|
| [Lab 01](./lab-01-active-directory/) | Active Directory — User, GPO & Security Policy Management | 2.4, 3.1, 4.6 | ✅ Complete |
| [Lab 02](./lab-02-wireshark/) | Wireshark & Network Traffic Analysis | 4.1, 4.4, 2.2 | ✅ Complete |
| [Lab 03](./lab-03-splunk-siem/) | Splunk SIEM & Log Analysis | 4.1, 4.3, 2.2 | ✅ Complete |
| [Lab 04](./lab-04-servicenow-itsm/) | ServiceNow ITSM — Incident & Change Management | 4.3, 5.3, 5.4 | ✅ Complete |
| [Lab 05](./lab-05-nessus-vulnerability/) | Nessus Vulnerability Scanning & Remediation | 4.3, 2.5, 5.1 | ✅ Complete |
| [Lab 06](./lab-06-azure-cloud-architecture/) | Azure Cloud Architecture & Engineering | 2.1, 3.2, 4.6 | ✅ Complete |

---

## Environment

| Component | Details |
|-----------|---------|
| **Cloud Platform** | Microsoft Azure |
| **VM Name** | HenryVM |
| **Resource Group** | HENRYVM_GROUP |
| **Location** | South Africa North |
| **Subscription** | Azure Subscription 1 |
| **VM Type** | Windows Server 2022 (Azure hosted) |

---

## Lab Architecture

```
Azure Cloud (South Africa North)
└── HenryVM (Windows Server 2022)
    ├── Active Directory Domain Services (Lab 01)
    ├── Wireshark + PCAP Analysis (Lab 02)
    ├── Splunk Enterprise + Universal Forwarder (Lab 03)
    ├── ServiceNow PDI (Lab 04 — browser-based)
    └── Nessus Essentials (Lab 05)
    └── Azure Cloud Architecture (Lab 06)
```

---

## Repository Structure

```
CyberKraft-SecurityPlus-Labs/
├── README.md                          ← This file
├── lab-01-active-directory/
│   ├── README.md                      ← Lab 01 full documentation
│   ├── screenshots/                   ← ADUC, GPO, Event Viewer captures
│   ├── scripts/                       ← PowerShell bulk-user creation scripts
│   ├── configs/                       ← GPO export XML configs
│   └── reports/                       ← Lab summary report
├── lab-02-wireshark/
│   ├── README.md                      ← Lab 02 full documentation
│   ├── screenshots/                   ← Annotated Wireshark captures
│   ├── pcap-samples/                  ← Sample PCAP file references
│   ├── filters/                       ← Wireshark display filter cheat sheet
│   └── reports/                       ← IOC summary report
├── lab-03-splunk-siem/
│   ├── README.md                      ← Lab 03 full documentation
│   ├── screenshots/                   ← Dashboard and alert screenshots
│   ├── spl-queries/                   ← SPL query library
│   ├── configs/                       ← Splunk forwarder config
│   ├── dashboards/                    ← Dashboard XML export
│   └── reports/                       ← Incident report
├── lab-04-servicenow-itsm/
│   ├── README.md                      ← Lab 04 full documentation
│   ├── screenshots/                   ← Incident, Change, Problem records
│   ├── workflows/                     ← ITSM lifecycle diagrams
│   └── reports/                       ← IR mapping document
├── lab-05-nessus-vulnerability/
│   ├── README.md                      ← Lab 05 full documentation
│   ├── screenshots/                   ← Before/after scan screenshots
│   ├── reports/                       ← Vulnerability assessment reports
│   └── remediation-logs/              ← Patch and remediation tracking
└── assets/
    └── diagrams/                      ← Network and architecture diagrams
```

---

## Security+ SY0-701 Domain Coverage

| Domain | Description | Labs Covered |
|--------|-------------|--------------|
| **2.2** | Threat Intelligence | Lab 02, Lab 03 |
| **2.4** | Identity & Access Management | Lab 01 |
| **2.5** | Vulnerability Scanning | Lab 05 |
| **3.1** | Security Architecture | Lab 01 |
| **4.1** | Monitoring & Detection | Lab 02, Lab 03 |
| **4.3** | Incident Response | Lab 03, Lab 04, Lab 05 |
| **4.4** | Network Security | Lab 02 |
| **4.6** | Hardening | Lab 01 |
| **5.1** | Security Governance | Lab 05 |
| **5.3** | Risk Management & Compliance | Lab 04 |
| **5.4** | Data Privacy | Lab 04 |

---

## Key Skills Demonstrated

- **Active Directory**: Domain setup, OU design, RBAC groups, GPO hardening, PowerShell automation
- **Network Analysis**: Packet capture, protocol analysis, IOC identification, Wireshark display filters
- **SIEM Operations**: Log ingestion, SPL queries, custom dashboards, alert rules, incident detection
- **ITSM Workflows**: Incident management, change management, SLA configuration, ITIL alignment
- **Vulnerability Management**: Authenticated vs. unauthenticated scanning, CVSS scoring, remediation tracking

---

## How to Use This Repository

Each lab folder contains a dedicated `README.md` with:
1. **Objective** — What the lab accomplishes and why it matters
2. **Environment Setup** — Step-by-step configuration instructions
3. **Execution Steps** — Detailed walkthrough of every action taken
4. **Evidence & Findings** — Screenshots, outputs, and analysis
5. **Security+ Domain Connections** — How each task maps to exam objectives
6. **Lessons Learned** — Key takeaways and real-world applications

---

## References

- [CompTIA Security+ SY0-701 Exam Objectives](https://www.comptia.org/certifications/security)
- [CyberKraft Training](https://cyberkraft.com)
- [MITRE ATT&CK Framework](https://attack.mitre.org)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [ITIL v4 Foundation](https://www.axelos.com/certifications/itil-service-management)

---

*Lab portfolio maintained by Henry Jenkins | CyberKraft Security+ Bootcamp | Azure VM: HenryVM (South Africa North)*
