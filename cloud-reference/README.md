# Cloud Architecture & Engineering Reference

This directory contains comprehensive reference documentation covering cloud architecture patterns, engineering principles, and Azure-specific security configurations relevant to the **CyberKraft Security+ SY0-701** lab series.

---

## Directory Structure

```
cloud-reference/
├── engineering-principles/
│   └── cloud-engineering-principles.md    # Core cloud engineering concepts
├── architecture-patterns/
│   └── azure-security-patterns.md         # Azure security architecture patterns
└── README.md                              # This file
```

---

## Security+ SY0-701 Cloud Domains Covered

| Domain | Topic | Reference Document |
|---|---|---|
| **2.2** | Summarize virtualization and cloud computing concepts | engineering-principles.md |
| **2.3** | Summarize secure application development, deployment, and automation | azure-security-patterns.md |
| **2.4** | Summarize authentication and authorization design concepts | azure-security-patterns.md |
| **3.1** | Given a scenario, implement secure protocols | engineering-principles.md |
| **4.1** | Given a scenario, apply cybersecurity solutions to the cloud | azure-security-patterns.md |
| **4.6** | Given a scenario, implement and maintain identity and access management | azure-security-patterns.md |

---

## Cloud Service Models

### IaaS — Infrastructure as a Service

**HenryVM** is a prime example of IaaS. Azure provides the physical hardware, networking, and hypervisor. The user manages the OS, middleware, runtime, data, and applications.

> **Security+ Relevance:** Understanding IaaS is critical for Domain 2.2. The shared responsibility model determines what security controls the user must implement versus what Azure handles natively.

### PaaS — Platform as a Service

Azure App Service, Azure SQL Database, and Azure Functions are PaaS offerings. The provider manages the OS and runtime; the user manages only the application and data.

### SaaS — Software as a Service

Microsoft 365, ServiceNow (Lab 04), and Splunk Cloud are SaaS examples. The provider manages everything; the user manages only data and access policies.

---

## Cloud Deployment Models

| Model | Description | Security+ Relevance |
|---|---|---|
| **Public Cloud** | Resources shared across tenants (Azure, AWS, GCP) | Domain 2.2 — multi-tenancy risks |
| **Private Cloud** | Dedicated infrastructure for one organization | Domain 2.2 — on-premises control |
| **Hybrid Cloud** | Mix of public and private | Domain 2.2 — connectivity security |
| **Community Cloud** | Shared by organizations with common concerns | Domain 2.2 — sector-specific compliance |

---

## Azure-Specific Security Engineering

### Microsoft Defender for Cloud

Provides unified security management and advanced threat protection across Azure workloads. Relevant to **Security+ Domain 4.1**.

### Azure Active Directory (Microsoft Entra ID)

Cloud-based identity and access management. Relevant to **Security+ Domain 4.6** — identity federation, MFA, conditional access.

### Azure Key Vault

Centralized secrets management for keys, certificates, and passwords. Relevant to **Security+ Domain 2.4** — key management.

### Azure Monitor & Log Analytics

Centralized logging and monitoring. Integrates with Splunk (Lab 03) via Azure Event Hub. Relevant to **Security+ Domain 4.3**.

---

*See individual documents in subdirectories for detailed coverage of each topic.*
