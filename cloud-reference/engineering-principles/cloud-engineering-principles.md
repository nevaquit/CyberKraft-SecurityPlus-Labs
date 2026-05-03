# Cloud Engineering Principles for Security+

> **A reference guide for applying cloud engineering concepts to the CyberKraft Security+ Labs.**

---

## 1. The Shared Responsibility Model

The Shared Responsibility Model dictates the security obligations of the Cloud Service Provider (CSP) versus the customer.

| Service Model | CSP Responsibility | Customer Responsibility | Example in Labs |
|---------------|--------------------|-------------------------|-----------------|
| **IaaS** (Infrastructure as a Service) | Physical datacenter, network fabric, host hypervisor | OS patching, network controls (NSGs), IAM, data security | HenryVM (Windows Server 2022) |
| **PaaS** (Platform as a Service) | OS patching, runtime environment, physical security | Application code, IAM, data security | Azure SQL Database (Not used in labs) |
| **SaaS** (Software as a Service) | Application code, OS, physical security | IAM, data security, endpoint protection | ServiceNow ITSM (Lab 04) |

---

## 2. High Availability (HA) & Fault Tolerance

Cloud engineering requires designing systems that remain operational despite component failures.

- **Availability Zones (AZs):** Deploying resources across physically separate datacenters within a region (e.g., South Africa North).
- **Load Balancing:** Distributing traffic across multiple instances to prevent single points of failure.
- **Redundancy:** Using Locally Redundant Storage (LRS) or Geo-Redundant Storage (GRS) for managed disks.

---

## 3. Infrastructure as Code (IaC)

IaC is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

- **Benefits:** Consistency, repeatability, version control, and rapid deployment.
- **Tools:** Azure Resource Manager (ARM) templates, Bicep, Terraform, PowerShell (used in Lab 06).

---

## 4. Zero Trust Architecture (ZTA)

Zero Trust assumes that threats exist both inside and outside the network. "Never trust, always verify."

- **Microsegmentation:** Dividing the network into smaller, isolated segments using Network Security Groups (NSGs) to restrict lateral movement.
- **Least Privilege:** Granting users and services only the minimum access necessary to perform their functions (applied in Lab 01 AD RBAC).
- **Continuous Verification:** Requiring Multi-Factor Authentication (MFA) and conditional access policies for all requests.

---

## 5. Cloud Security Posture Management (CSPM)

CSPM tools continuously monitor cloud environments for misconfigurations, compliance violations, and security risks.

- **Azure Security Center / Microsoft Defender for Cloud:** Provides secure score, recommendations, and Just-In-Time (JIT) VM access.
- **Integration:** Nessus (Lab 05) can be integrated with CSPM tools to provide a comprehensive view of vulnerabilities across the cloud estate.

---

## 6. Scalability & Elasticity

- **Scalability:** The ability to handle increased workload by adding resources (scaling up/vertical) or adding instances (scaling out/horizontal).
- **Elasticity:** The ability to automatically scale resources up or down based on demand, optimizing costs and performance.

---

*Reference: CompTIA Security+ SY0-701 Exam Objectives (Domain 2.1, 3.2)*
