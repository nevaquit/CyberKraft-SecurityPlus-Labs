# Azure Security Architecture Patterns

> **A reference guide for secure cloud architecture patterns applied in the CyberKraft Security+ Labs.**

---

## 1. Hub-Spoke Network Topology

The Hub-Spoke topology is the recommended architecture for enterprise Azure deployments.

- **Hub VNet:** Acts as a central point of connectivity to many spoke VNets. It hosts shared services like Azure Firewall, VPN Gateways, and Bastion hosts.
- **Spoke VNets:** Host the actual workloads (like HenryVM). They peer with the Hub VNet but are isolated from each other by default.
- **Security Benefit:** Centralizes security controls and inspection. All traffic entering or leaving the spokes must pass through the Hub's security appliances.

---

## 2. Zero Trust Identity (Azure AD / Entra ID)

Identity is the primary security perimeter in the cloud.

- **Conditional Access:** Policies that evaluate signals (user location, device health, risk level) before granting access.
- **Multi-Factor Authentication (MFA):** Enforced for all administrative access.
- **Privileged Identity Management (PIM):** Provides Just-In-Time (JIT) privileged access to Azure resources, reducing the exposure time of admin accounts.

---

## 3. Defense in Depth (Network Layer)

Multiple layers of network security controls:

1. **Azure DDoS Protection:** Basic protection is enabled by default on all public IPs.
2. **Azure Firewall:** Stateful firewall deployed in the Hub VNet for deep packet inspection.
3. **Network Security Groups (NSGs):** Applied at the subnet and NIC levels to enforce microsegmentation (used in Lab 06).
4. **Application Security Groups (ASGs):** Group VMs by workload (e.g., "WebServers", "DbServers") to simplify NSG rule management.

---

## 4. Data Security & Encryption

- **Encryption at Rest:** Azure Storage Service Encryption (SSE) is enabled by default using Microsoft-managed keys.
- **Encryption in Transit:** Enforcing TLS 1.2+ for all web traffic (e.g., Splunk Web, Nessus Web).
- **Azure Key Vault:** Centralized management of cryptographic keys, secrets, and certificates.

---

## 5. Cloud Security Posture Management (CSPM)

- **Microsoft Defender for Cloud:** Continuously assesses the security posture of Azure resources against compliance frameworks (e.g., CIS, NIST).
- **Just-In-Time (JIT) VM Access:** Blocks inbound RDP/SSH ports by default. When an admin requests access, the port is opened for a limited time (e.g., 1 hour) from a specific source IP.

---

*Reference: Microsoft Azure Well-Architected Framework - Security Pillar*
