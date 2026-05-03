# Lab 06 — Azure Cloud Architecture & Engineering

> **Objective:** Design, deploy, and secure a cloud-native architecture in Microsoft Azure, applying cloud engineering principles (IaaS, PaaS, SaaS) and implementing the Shared Responsibility Model.

---

## 1. Cloud Architecture Overview

This lab transitions the traditional on-premises security concepts from Labs 01–05 into a modern cloud environment. We will architect a secure foundation in Azure, focusing on network segmentation, identity integration, and resource protection.

### 1.1 Architecture Diagram
*(See `diagrams/azure-secure-architecture.png` for the visual topology)*

The architecture consists of:
- **VNet (Virtual Network):** `10.0.0.0/16`
- **Public Subnet:** `10.0.1.0/24` (Jumpbox / Bastion Host)
- **Private Subnet:** `10.0.2.0/24` (HenryVM - Core Services)
- **Security:** Network Security Groups (NSGs), Azure Firewall, Azure AD (Entra ID)

---

## 2. Cloud Engineering Principles Applied

### 2.1 The Shared Responsibility Model
In this IaaS (Infrastructure as a Service) deployment:
- **Microsoft Azure is responsible for:** Physical security, host infrastructure, and network fabric.
- **We are responsible for:** OS patching (Windows Server 2022), network controls (NSGs), identity management (AD DS), and application security (Splunk, Nessus).

### 2.2 High Availability & Fault Tolerance
- **Availability Zones:** Resources deployed across multiple zones in `South Africa North` to ensure resilience against datacenter failures.
- **Managed Disks:** Premium SSDs with LRS (Locally Redundant Storage) for high IOPS and data durability.

### 2.3 Zero Trust Network Access (ZTNA)
- **Microsegmentation:** Strict NSG rules applied at the subnet and NIC levels.
- **Just-In-Time (JIT) Access:** RDP (Port 3389) is blocked by default and only opened via Azure Security Center JIT requests.

---

## 3. Execution Steps

### Step 1: Virtual Network (VNet) Deployment
1. Created `CyberKraft-VNet` in the `HENRYVM_GROUP` resource group.
2. Defined address space `10.0.0.0/16`.
3. Created `Subnet-Public` and `Subnet-Private`.

### Step 2: Network Security Group (NSG) Configuration
1. Created `NSG-Private-Tier`.
2. Configured inbound security rules:
   - **Allow-Splunk-Web:** Port 8000 (TCP) from specific trusted IPs.
   - **Allow-Nessus-Web:** Port 8834 (TCP) from specific trusted IPs.
   - **Deny-All-Inbound:** Priority 4096 (Implicit Deny).

### Step 3: Identity & Access Management (IAM)
1. Integrated Azure AD (Entra ID) with the local Active Directory domain (`cyberkraft.local`) built in Lab 01.
2. Configured Azure AD Connect for hybrid identity synchronization.
3. Enforced Multi-Factor Authentication (MFA) for all administrative access to the Azure Portal.

---

## 4. Security+ SY0-701 Domain Connections

- **2.1 Cloud Concepts:** IaaS, PaaS, SaaS, Shared Responsibility Model.
- **3.2 Cloud Architecture:** Virtual Private Cloud (VPC/VNet), Transit Gateways, Security Groups.
- **4.6 Hardening:** Cloud posture management, disabling default accounts, restricting management interfaces.

---

## 5. Lessons Learned

- **Cloud is not inherently secure:** While Azure provides a secure foundation, the configuration of the OS, applications, and network access remains the customer's responsibility.
- **Identity is the new perimeter:** In cloud environments, robust IAM (like Azure AD with MFA) is more critical than traditional network firewalls.
- **Automation is key:** Deploying cloud resources via Infrastructure as Code (IaC) or PowerShell ensures consistency and reduces human error compared to manual portal configuration.
