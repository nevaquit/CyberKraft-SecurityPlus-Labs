# Lab 02 — Wireshark & Network Traffic Analysis

**SY0-701 Domains:** 4.1 Monitoring & Detection · 4.4 Network Security · 2.2 Threat Intelligence

---

## Why This Lab Matters

Network traffic analysis is a foundational skill for SOC analysts, network engineers, and incident responders. Wireshark is the industry-standard tool for capturing and dissecting packets. This lab demonstrates the ability to identify normal vs. malicious traffic patterns, extract Indicators of Compromise (IOCs), and apply display filters — all critical skills tested on the Security+ exam and demanded in entry-level security roles.

### Cloud Architecture Integration
In a cloud environment like Azure (detailed in **Lab 06**), traditional network taps are replaced by features like Azure Network Watcher Packet Capture. However, the fundamental skill of analyzing the resulting PCAP files in Wireshark remains identical. Understanding how traffic flows through Virtual Networks (VNets) and Network Security Groups (NSGs) is critical when investigating cloud-based incidents.

---

## Environment

| Component | Details |
|-----------|---------|
| **Platform** | Microsoft Azure — HenryVM (South Africa North) |
| **OS** | Windows Server 2022 |
| **Tool** | Wireshark 4.x |
| **Network Interface** | Azure vNIC (10.0.0.x subnet) |
| **Traffic Types Analyzed** | HTTP, HTTPS/TLS, DNS, ICMP, ARP, TCP SYN scan |

---

## Objectives

1. Install and configure Wireshark on HenryVM
2. Capture live network traffic on the Azure VM NIC
3. Apply display filters to isolate specific protocols
4. Identify and document normal traffic patterns
5. Analyze suspicious traffic patterns (port scans, cleartext credentials)
6. Extract IOCs from packet captures
7. Export findings in a structured report

---

## Step-by-Step Execution

### Phase 1: Installation

**Download and install Wireshark:**

```powershell
# Download Wireshark installer
$WiresharkURL = "https://2.na.dl.wireshark.org/win64/Wireshark-4.4.0-x64.exe"
$InstallerPath = "C:\Temp\Wireshark-installer.exe"
Invoke-WebRequest -Uri $WiresharkURL -OutFile $InstallerPath

# Silent install with Npcap (required for packet capture)
Start-Process -FilePath $InstallerPath -ArgumentList "/S /desktopicon=yes" -Wait
```

**Verify installation:**

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

---

### Phase 2: Live Traffic Capture

**Identify available network interfaces:**

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

Expected output:
```
1. \Device\NPF_{GUID} (Ethernet — Azure vNIC)
2. \Device\NPF_Loopback (Loopback)
```

**Start a 5-minute capture on the primary interface:**

```powershell
$CaptureFile = "C:\Captures\henryvm_capture_$(Get-Date -Format 'yyyyMMdd_HHmmss').pcapng"
New-Item -ItemType Directory -Path "C:\Captures" -Force | Out-Null

# Capture 300 seconds of traffic
& "C:\Program Files\Wireshark\tshark.exe" `
    -i 1 `
    -a duration:300 `
    -w $CaptureFile `
    -q
    
Write-Host "Capture saved to: $CaptureFile"
```

**Generate test traffic during capture:**

```powershell
# Generate DNS queries
Resolve-DnsName google.com
Resolve-DnsName microsoft.com
Resolve-DnsName github.com

# Generate ICMP (ping)
Test-Connection -ComputerName 8.8.8.8 -Count 10

# Generate HTTP traffic
Invoke-WebRequest -Uri "http://example.com" -UseBasicParsing

# Generate HTTPS traffic
Invoke-WebRequest -Uri "https://www.microsoft.com" -UseBasicParsing
```

---

### Phase 3: Wireshark Display Filters

The following display filters were applied and documented:

#### Protocol Isolation Filters

| Filter | Purpose | Expected Output |
|--------|---------|-----------------|
| `dns` | Show only DNS traffic | DNS queries and responses |
| `http` | Show only HTTP traffic | Cleartext web requests |
| `tls` | Show only TLS/HTTPS traffic | Encrypted web traffic |
| `icmp` | Show only ICMP traffic | Ping requests/replies |
| `arp` | Show only ARP traffic | MAC-to-IP resolution |
| `tcp` | Show all TCP traffic | All TCP connections |
| `udp` | Show all UDP traffic | DNS, NTP, DHCP |

#### Security Investigation Filters

| Filter | Purpose | Threat Indicator |
|--------|---------|------------------|
| `tcp.flags.syn == 1 && tcp.flags.ack == 0` | TCP SYN packets only | Port scanning activity |
| `tcp.flags == 0x002` | SYN-only (no ACK) | Half-open scan (Nmap -sS) |
| `http.request.method == "POST"` | HTTP POST requests | Credential submission |
| `ftp` | FTP traffic | Cleartext credential risk |
| `telnet` | Telnet traffic | Cleartext session risk |
| `dns.qry.name contains "."` | All DNS queries | DNS exfiltration check |
| `ip.addr == 10.0.0.4` | Traffic to/from DC | Domain controller monitoring |
| `tcp.port == 445` | SMB traffic | Lateral movement / ransomware |
| `tcp.port == 3389` | RDP traffic | Remote access monitoring |
| `tcp.analysis.retransmission` | TCP retransmissions | Network issues / DoS indicator |
| `!(arp or dns or icmp)` | Exclude common noise | Focus on application traffic |

#### Credential Exposure Filters

| Filter | Purpose |
|--------|---------|
| `http.authorization` | HTTP Basic Auth headers (cleartext) |
| `ftp.request.command == "PASS"` | FTP password in cleartext |
| `smtp.auth.password` | SMTP authentication password |
| `pop.request.command == "PASS"` | POP3 password in cleartext |

---

### Phase 4: Traffic Analysis Scenarios

#### Scenario A — Normal DNS Resolution

**Filter:** `dns`

**Observation:** DNS queries from `10.0.0.4` to Azure DNS resolver (`168.63.129.16`). Standard A record lookups for `google.com`, `microsoft.com`. Response times under 5ms. No unusual query types (no TXT, AXFR, or high-frequency queries that would indicate DNS tunneling).

**Verdict:** Normal traffic. No IOCs.

---

#### Scenario B — HTTP Cleartext Traffic

**Filter:** `http`

**Observation:** HTTP GET request to `http://example.com`. Full request headers visible including `User-Agent`, `Host`, and `Accept` headers. Response body visible in cleartext.

**Key Finding:** HTTP traffic exposes all data in plaintext. Any credentials submitted via HTTP forms would be visible to a network eavesdropper.

**Verdict:** Risk identified. Recommendation: enforce HTTPS-only via HSTS.

**Relevant Packet Fields:**
```
Frame: 142
Source IP: 10.0.0.4
Destination IP: 93.184.216.34
Protocol: HTTP
Info: GET / HTTP/1.1
  Host: example.com
  User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)
  Accept: */*
```

---

#### Scenario C — TLS Handshake Analysis

**Filter:** `tls.handshake.type == 1` (Client Hello)

**Observation:** TLS 1.3 Client Hello packets to `microsoft.com`. Server Name Indication (SNI) field reveals the destination hostname even in encrypted traffic. Cipher suites negotiated include `TLS_AES_256_GCM_SHA384`.

**Key Finding:** Even encrypted HTTPS traffic leaks the destination hostname via SNI. This is a known privacy concern addressed by Encrypted Client Hello (ECH).

**Verdict:** Normal encrypted traffic. SNI metadata visible.

---

#### Scenario D — Simulated Port Scan Detection

**Simulated scan using PowerShell:**

```powershell
# Simulate a basic port scan (for lab purposes only)
1..1024 | ForEach-Object {
    $Socket = New-Object System.Net.Sockets.TcpClient
    $Connect = $Socket.BeginConnect("10.0.0.4", $_, $null, $null)
    $Wait = $Connect.AsyncWaitHandle.WaitOne(50, $false)
    if ($Wait) { Write-Host "Port $_ OPEN" }
    $Socket.Close()
}
```

**Filter:** `tcp.flags.syn == 1 && tcp.flags.ack == 0`

**Observation:** Burst of TCP SYN packets from `10.0.0.5` to `10.0.0.4` across sequential ports (1, 2, 3, 4...). No corresponding SYN-ACK responses for closed ports. Classic half-open scan signature.

**IOCs Identified:**
- Source IP: `10.0.0.5`
- Destination IP: `10.0.0.4`
- Pattern: Sequential port enumeration
- Rate: ~200 SYN packets per second
- MITRE ATT&CK: T1046 — Network Service Discovery

**Verdict:** Suspicious. Indicative of reconnaissance activity. Should trigger SIEM alert.

---

#### Scenario E — ICMP Analysis

**Filter:** `icmp`

**Observation:** Standard ICMP Echo Request/Reply pairs between `10.0.0.4` and `8.8.8.8`. TTL values consistent with expected hop counts. Payload size: 32 bytes (Windows default).

**Abnormal ICMP Indicators to watch for:**
- ICMP payload > 64 bytes (possible data exfiltration)
- ICMP to unusual destinations
- High-frequency ICMP (flood/DoS)

**Verdict:** Normal traffic. No IOCs.

---

### Phase 5: IOC Summary

| IOC Type | Value | Scenario | Severity | Action |
|----------|-------|----------|----------|--------|
| Cleartext Protocol | HTTP on port 80 | B | Medium | Enforce HTTPS |
| Port Scan | Sequential SYN from 10.0.0.5 | D | High | Block source, alert SIEM |
| SNI Metadata Leak | Hostname in TLS Client Hello | C | Low | Monitor, consider ECH |

---

### Phase 6: Wireshark Statistics

**Protocol Hierarchy** (`Statistics > Protocol Hierarchy`):

| Protocol | % of Packets | Notes |
|----------|-------------|-------|
| TCP | 68.4% | Dominant — web and AD traffic |
| UDP | 18.2% | DNS, NTP |
| ICMP | 8.1% | Ping tests |
| ARP | 5.3% | MAC resolution |

**Conversations** (`Statistics > Conversations > TCP`):
- Top talker: `10.0.0.4:49152` ↔ `20.190.159.10:443` (Microsoft Azure services)
- Second: `10.0.0.4:53` ↔ `168.63.129.16:53` (Azure DNS)

---

## Wireshark Display Filter Cheat Sheet

See [`filters/wireshark-filters.md`](./filters/wireshark-filters.md) for the complete reference.

---

## Evidence & Findings

### Screenshot Inventory

| File | Description |
|------|-------------|
| `screenshots/01-wireshark-main-interface.png` | Wireshark interface with live capture |
| `screenshots/02-dns-filter.png` | DNS traffic filtered view |
| `screenshots/03-http-cleartext.png` | HTTP cleartext traffic with headers visible |
| `screenshots/04-tls-client-hello.png` | TLS 1.3 handshake with SNI visible |
| `screenshots/05-syn-scan-detection.png` | TCP SYN scan burst pattern |
| `screenshots/06-protocol-hierarchy.png` | Protocol hierarchy statistics |
| `screenshots/07-conversations-tcp.png` | TCP conversations statistics |
| `screenshots/08-icmp-analysis.png` | ICMP echo request/reply pairs |
| `screenshots/09-follow-tcp-stream.png` | Following a TCP stream (HTTP) |
| `screenshots/10-export-objects.png` | HTTP object export |

---

## Security+ Domain Connections

| Action Performed | SY0-701 Domain | Concept |
|-----------------|----------------|---------|
| Packet capture and protocol analysis | 4.1 Monitoring & Detection | Network monitoring, traffic analysis |
| Identifying cleartext protocols | 4.4 Network Security | Protocol security, encryption requirements |
| Port scan detection | 2.2 Threat Intelligence | Reconnaissance, IOC identification |
| TLS handshake analysis | 4.4 Network Security | Encryption, certificate validation |
| IOC extraction and documentation | 4.1 Monitoring & Detection | Indicator analysis, threat hunting |

---

## Lessons Learned

**Cleartext Protocols are a Real Risk:** HTTP, FTP, and Telnet transmit data in plaintext. A single Wireshark capture on a shared network segment can expose usernames, passwords, and session tokens. This reinforces why TLS/HTTPS is mandatory.

**Port Scans are Noisy and Detectable:** A TCP SYN scan generates a distinctive burst of SYN packets with no corresponding ACK responses. This pattern is easily detected by Wireshark, IDS/IPS systems, and SIEM tools. Defenders should alert on this pattern.

**SNI Leaks Destination Hostnames:** Even encrypted HTTPS traffic reveals the destination hostname in the TLS Client Hello SNI field. This means network monitoring tools can see which websites a user visits even without decrypting traffic.

**Statistics Views Accelerate Analysis:** Wireshark's Protocol Hierarchy and Conversations views provide instant situational awareness. Rather than reading individual packets, these views show the big picture of what's happening on the network.

---

## References

- [Wireshark Display Filter Reference](https://www.wireshark.org/docs/dfref/)
- [MITRE ATT&CK: T1046 Network Service Discovery](https://attack.mitre.org/techniques/T1046/)
- [MITRE ATT&CK: T1040 Network Sniffing](https://attack.mitre.org/techniques/T1040/)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
- [CompTIA Security+ SY0-701 Domain 4.1](https://www.comptia.org/certifications/security)
