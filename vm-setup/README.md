# HenryVM — Azure Lab Environment Setup

This document records the complete setup and configuration of **HenryVM**, the Azure virtual machine used to perform all CyberKraft Security+ SY0-701 labs.

---

## VM Specifications

| Property | Value |
|---|---|
| **VM Name** | HenryVM |
| **Operating System** | Windows Server 2025 Datacenter Azure Edition |
| **VM Size** | Standard B2as v2 (2 vCPUs, 8 GiB RAM) |
| **Subscription** | Azure subscription 1 (`57e0f2ca-c6dc-411f-857b-e4650162919e`) |
| **Resource Group** | HENRYVM_GROUP |
| **Region** | South Africa North (Zone 1) |
| **Public IP** | 102.133.145.67 |
| **Private IP** | 10.0.0.5 |
| **VM Agent** | Ready |
| **Availability Zone** | Zone 1 |

---

## Cloud Architecture Context

HenryVM is deployed within a standard **Azure IaaS (Infrastructure as a Service)** architecture. The following cloud engineering principles govern its design:

### Azure Resource Hierarchy

```
Azure Account (nevaquitgmail.onmicrosoft.com)
└── Subscription: Azure subscription 1
    └── Resource Group: HENRYVM_GROUP
        ├── Virtual Machine: HenryVM (Windows Server 2025)
        ├── Network Interface: HenryVM-nic
        ├── Virtual Network: HenryVM-vnet (10.0.0.0/16)
        │   └── Subnet: default (10.0.0.0/24)
        ├── Network Security Group: HenryVM-nsg
        ├── Public IP Address: HenryVM-ip (102.133.145.67)
        └── OS Disk: HenryVM_OsDisk (Premium SSD)
```

### Cloud Engineering Principles Applied

| Principle | Implementation |
|---|---|
| **Least Privilege** | NSG rules restrict inbound traffic to RDP (3389) only |
| **Defense in Depth** | Azure Defender + Windows Defender + NSG layered security |
| **Scalability** | B2as v2 size supports vertical scaling for lab workloads |
| **High Availability** | Zone 1 placement with Azure SLA of 99.9% uptime |
| **Cost Optimization** | Auto-shutdown configured to reduce idle compute costs |
| **Infrastructure as Code** | All setup scripts stored in GitHub for reproducibility |

---

## Phase 1 — Core Tools Installation

**Executed via:** Azure Run Command (RunPowerShellScript)
**Date:** 2026-05-03
**Status:** ✅ Complete

### Tools Installed

| Tool | Purpose | Lab |
|---|---|---|
| **Chocolatey** | Windows package manager | All labs |
| **Wireshark** | Network protocol analyzer | Lab 02 |
| **Git** | Version control | All labs |
| **Nmap** | Network scanner | Lab 05 |

### Lab Directory Structure Created

```
C:\CyberKraft-Labs\
├── Lab01-ActiveDirectory\
│   ├── scripts\
│   └── reports\
├── Lab02-Wireshark\
│   ├── captures\
│   └── reports\
├── Lab03-Splunk\
│   ├── configs\
│   └── queries\
├── Lab04-ServiceNow\
│   └── workflows\
├── Lab05-Nessus\
│   ├── scans\
│   └── remediation\
├── Lab06-AzureCloud\
│   ├── scripts\
│   └── reports\
└── Logs\
    └── setup-phase1.log
```

---

## Phase 2 — Windows Server Roles & Features

**Executed via:** Azure Run Command (RunPowerShellScript)
**Date:** 2026-05-03
**Status:** ✅ Complete

### Windows Features Installed

| Feature | Display Name | Purpose |
|---|---|---|
| `AD-Domain-Services` | Active Directory Domain Services | Lab 01 |
| `DNS` | DNS Server | Lab 01 |
| `RSAT-AD-Tools` | AD Remote Server Admin Tools | Lab 01 |
| `RSAT-DNS-Server` | DNS Remote Server Admin Tools | Lab 01 |

### Audit Policies Configured

| Category | Success | Failure |
|---|---|---|
| Account Logon | ✅ | ✅ |
| Logon/Logoff | ✅ | ✅ |
| Object Access | ✅ | ✅ |
| Policy Change | ✅ | ✅ |
| Privilege Use | ✅ | ✅ |
| System | ✅ | ✅ |

### Windows Defender Configuration

- Real-time monitoring: **Enabled**
- Network protection: **Enabled**
- Cloud-delivered protection: **Enabled** (Azure Defender integration)

### Event Logs Enabled (for Splunk SIEM)

- `Security` (104 MB max size)
- `System` (104 MB max size)
- `Application` (104 MB max size)
- `Microsoft-Windows-PowerShell/Operational`
- `Microsoft-Windows-Sysmon/Operational`

---

## Phase 3 — Security Hardening & Lab Configuration

**Executed via:** Azure Run Command (RunPowerShellScript)
**Date:** 2026-05-03
**Status:** ✅ Complete

### Security Configurations Applied

| Configuration | Value | Security+ Domain |
|---|---|---|
| Password minimum length | 12 characters | 2.4 |
| Password complexity | Enabled | 2.4 |
| Account lockout threshold | 5 attempts | 2.4 |
| Account lockout duration | 30 minutes | 2.4 |
| RDP encryption level | High (FIPS) | 2.5 |
| SMBv1 | Disabled | 4.1 |
| Windows Firewall | Enabled (all profiles) | 4.6 |
| TLS 1.0/1.1 | Disabled | 2.5 |
| TLS 1.2/1.3 | Enabled | 2.5 |
| PowerShell Script Block Logging | Enabled | 4.3 |
| LAPS (Local Admin Password Solution) | Configured | 2.4 |

---

## Network Security Group Rules

| Priority | Name | Port | Protocol | Source | Action |
|---|---|---|---|---|---|
| 300 | AllowRDP | 3389 | TCP | My IP | Allow |
| 65000 | AllowVnetInBound | Any | Any | VirtualNetwork | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Any | Any | AzureLoadBalancer | Allow |
| 65500 | DenyAllInBound | Any | Any | Any | Deny |

---

## Azure Cloud Engineering Concepts Demonstrated

### 1. Infrastructure as a Service (IaaS)

HenryVM represents the core IaaS model where the cloud provider (Microsoft Azure) manages the physical hardware, hypervisor, and network fabric, while the user manages the OS, middleware, and applications. This is directly relevant to **Security+ Domain 2.2** (Cloud Models).

### 2. Shared Responsibility Model

| Layer | Responsibility |
|---|---|
| Physical datacenter | Microsoft Azure |
| Network infrastructure | Microsoft Azure |
| Hypervisor | Microsoft Azure |
| Operating System | User (Henry Jenkins) |
| Applications | User (Henry Jenkins) |
| Data | User (Henry Jenkins) |
| Identity & Access | Shared |

### 3. Azure Security Center Integration

HenryVM is monitored by **Microsoft Defender for Cloud**, which provides:
- Continuous security assessment
- Threat protection for Windows Server workloads
- Regulatory compliance tracking (CIS, NIST)
- Just-in-time VM access recommendations

### 4. Availability and Resilience

- **Availability Zone 1**: Physical separation from other zones in South Africa North
- **Azure SLA**: 99.9% uptime for single-instance VMs with Premium SSD
- **Backup**: Azure Backup can be configured for RPO/RTO compliance

---

## Installation Scripts Reference

All installation scripts are stored in the repository at:

```
vm-setup/
├── Phase1-CoreTools.ps1       # Chocolatey, Wireshark, Git, Nmap
├── Phase2-WindowsRoles.ps1    # AD DS, DNS, RSAT, Audit Policies
├── Phase3-Hardening.ps1       # Security hardening, TLS, SMB, Firewall
└── README.md                  # This document
```

---

## Accessing HenryVM

### Via RDP

```
Host: 102.133.145.67
Port: 3389
Username: Henry Jenkins (local admin)
```

### Via Azure Bastion (Recommended for Production)

Azure Bastion provides browser-based RDP/SSH without exposing port 3389 to the internet — a key cloud security engineering principle.

```
Portal: https://portal.azure.com
Navigate: HenryVM → Connect → Bastion
```

### Via Azure Run Command

Used throughout this lab for automated script execution without requiring RDP connectivity:

```
Portal: HenryVM → Operations → Run command → RunPowerShellScript
```

---

*Last updated: 2026-05-03 | Environment: HenryVM, South Africa North | OS: Windows Server 2025 Datacenter Azure Edition*
