# Lab 02 IOC Summary Report — Wireshark Network Analysis

**Lab:** CyberKraft Security+ Lab 02
**Title:** Wireshark & Network Traffic Analysis
**Analyst:** Henry Jenkins
**Date:** May 3, 2026
**Platform:** Azure HenryVM (South Africa North)
**Capture Duration:** 300 seconds (5 minutes)

---

## Capture Summary

| Metric | Value |
|--------|-------|
| Total packets captured | 4,847 |
| Capture duration | 5 minutes |
| Network interface | Azure vNIC (10.0.0.x) |
| Capture file size | ~2.3 MB |
| Protocols observed | TCP, UDP, ICMP, ARP, DNS, HTTP, TLS |

---

## Protocol Distribution

| Protocol | Packets | Percentage |
|----------|---------|------------|
| TCP | 3,315 | 68.4% |
| UDP | 882 | 18.2% |
| ICMP | 392 | 8.1% |
| ARP | 258 | 5.3% |
| **Total** | **4,847** | **100%** |

---

## Indicators of Compromise (IOCs)

| IOC ID | Type | Value | Severity | Scenario | MITRE ATT&CK |
|--------|------|-------|----------|----------|--------------|
| IOC-001 | Cleartext Protocol | HTTP on port 80 from 10.0.0.4 | Medium | B | T1040 |
| IOC-002 | Port Scan | Sequential SYN from 10.0.0.5 | High | D | T1046 |
| IOC-003 | Metadata Leak | TLS SNI hostname visible | Low | C | T1040 |

---

## Scenario Findings

### Scenario B — HTTP Cleartext (IOC-001)
- **Source:** 10.0.0.4
- **Destination:** 93.184.216.34 (example.com)
- **Protocol:** HTTP (port 80)
- **Risk:** All data transmitted in plaintext, including any credentials
- **Recommendation:** Enforce HTTPS-only; implement HSTS header

### Scenario D — Port Scan (IOC-002)
- **Source:** 10.0.0.5
- **Destination:** 10.0.0.4
- **Pattern:** Sequential TCP SYN packets, ports 1-1024
- **Rate:** ~200 SYN/second
- **Risk:** Active reconnaissance of domain controller
- **Recommendation:** Block source IP, investigate WKSTN-005, alert SIEM

### Scenario C — TLS SNI Leak (IOC-003)
- **Protocol:** TLS 1.3 Client Hello
- **Leaked Data:** Destination hostname in SNI field
- **Risk:** Network monitoring can identify visited websites without decryption
- **Recommendation:** Monitor, consider Encrypted Client Hello (ECH) when available

---

## Recommendations

1. **Disable HTTP (port 80):** Force all web traffic to HTTPS. Configure IIS to redirect HTTP to HTTPS.
2. **Deploy IDS/IPS:** Implement Suricata or Snort to automatically detect port scans.
3. **Feed IOCs to Splunk:** The port scan source IP (10.0.0.5) should be added as a watchlist in Splunk.
4. **Network Segmentation:** Isolate the domain controller on a separate VLAN to limit scan exposure.

---

*Report by Henry Jenkins | CyberKraft Lab 02 | Azure HenryVM*
