# Wireshark Display Filter Reference

> CyberKraft Security+ Lab 02 — Wireshark & Network Traffic Analysis
> Azure VM: HenryVM | SY0-701 Domain: 4.1, 4.4

---

## Protocol Filters

| Filter | Description |
|--------|-------------|
| `dns` | All DNS traffic |
| `http` | All HTTP traffic (cleartext) |
| `tls` | All TLS/HTTPS traffic |
| `ssl` | Legacy SSL traffic |
| `ftp` | FTP control channel |
| `ftp-data` | FTP data transfer |
| `smtp` | SMTP email traffic |
| `pop` | POP3 email retrieval |
| `imap` | IMAP email traffic |
| `icmp` | ICMP (ping) traffic |
| `icmpv6` | ICMPv6 traffic |
| `arp` | ARP requests and replies |
| `tcp` | All TCP traffic |
| `udp` | All UDP traffic |
| `dhcp` | DHCP lease requests |
| `ntp` | Network Time Protocol |
| `ldap` | LDAP directory queries |
| `kerberos` | Kerberos authentication |
| `smb` | SMB file sharing |
| `smb2` | SMB2 file sharing |
| `rdp` | Remote Desktop Protocol |
| `ssh` | SSH traffic |
| `telnet` | Telnet (cleartext) |
| `snmp` | SNMP management traffic |
| `syslog` | Syslog messages |

---

## IP Address Filters

| Filter | Description |
|--------|-------------|
| `ip.addr == 10.0.0.4` | Traffic to or from specific IP |
| `ip.src == 10.0.0.4` | Traffic from specific source IP |
| `ip.dst == 10.0.0.4` | Traffic to specific destination IP |
| `ip.addr == 10.0.0.0/24` | Traffic within a subnet |
| `!(ip.addr == 10.0.0.1)` | Exclude specific IP |
| `ip.ttl < 10` | Low TTL (possible traceroute) |

---

## Port Filters

| Filter | Description |
|--------|-------------|
| `tcp.port == 80` | HTTP (port 80) |
| `tcp.port == 443` | HTTPS (port 443) |
| `tcp.port == 22` | SSH (port 22) |
| `tcp.port == 3389` | RDP (port 3389) |
| `tcp.port == 445` | SMB (port 445) |
| `tcp.port == 21` | FTP control (port 21) |
| `tcp.port == 25` | SMTP (port 25) |
| `tcp.port == 53` | DNS over TCP (port 53) |
| `udp.port == 53` | DNS over UDP (port 53) |
| `udp.port == 67 or udp.port == 68` | DHCP |
| `tcp.dstport == 80` | HTTP destination port |
| `tcp.srcport > 1024` | Ephemeral source ports |

---

## TCP Flag Filters (Security Investigation)

| Filter | Description | Threat Indicator |
|--------|-------------|------------------|
| `tcp.flags.syn == 1 && tcp.flags.ack == 0` | SYN-only packets | Port scanning |
| `tcp.flags == 0x002` | SYN flag set only | Half-open scan (nmap -sS) |
| `tcp.flags == 0x001` | FIN-only | FIN scan |
| `tcp.flags == 0x029` | SYN+FIN+URG | Xmas scan |
| `tcp.flags == 0x000` | NULL scan (no flags) | NULL scan |
| `tcp.flags.reset == 1` | RST packets | Connection resets |
| `tcp.analysis.retransmission` | Retransmissions | Network issues / DoS |
| `tcp.analysis.duplicate_ack` | Duplicate ACKs | Packet loss indicator |
| `tcp.analysis.out_of_order` | Out-of-order segments | Network instability |

---

## DNS Investigation Filters

| Filter | Description | Threat Indicator |
|--------|-------------|------------------|
| `dns.qry.name contains "."` | All DNS queries | Baseline |
| `dns.flags.rcode != 0` | DNS errors (NXDOMAIN etc.) | Possible DGA activity |
| `dns.qry.type == 16` | TXT record queries | DNS tunneling |
| `dns.qry.type == 252` | AXFR zone transfer | Unauthorized zone transfer |
| `dns.resp.len > 512` | Large DNS responses | DNS amplification |
| `dns.count.answers > 10` | Many DNS answers | Suspicious response |

---

## HTTP Investigation Filters

| Filter | Description |
|--------|-------------|
| `http.request` | All HTTP requests |
| `http.response` | All HTTP responses |
| `http.request.method == "GET"` | HTTP GET requests |
| `http.request.method == "POST"` | HTTP POST (credential submission) |
| `http.request.method == "PUT"` | HTTP PUT (file upload) |
| `http.authorization` | HTTP Basic Auth header (cleartext) |
| `http.response.code == 200` | Successful responses |
| `http.response.code == 401` | Unauthorized (auth failure) |
| `http.response.code == 404` | Not found |
| `http.response.code == 500` | Server error |
| `http.user_agent contains "curl"` | curl user agent |
| `http.user_agent contains "python"` | Python requests (possible automation) |
| `http.user_agent contains "nmap"` | Nmap HTTP scan |

---

## Credential Exposure Filters

| Filter | Description |
|--------|-------------|
| `http.authorization` | HTTP Basic Auth (Base64 encoded) |
| `ftp.request.command == "PASS"` | FTP password (cleartext) |
| `ftp.request.command == "USER"` | FTP username (cleartext) |
| `smtp.auth.password` | SMTP auth password |
| `pop.request.command == "PASS"` | POP3 password (cleartext) |
| `telnet` | All Telnet (everything cleartext) |

---

## Malware / C2 Traffic Filters

| Filter | Description | Threat Indicator |
|--------|-------------|------------------|
| `http.request.uri contains ".exe"` | EXE download via HTTP | Malware download |
| `http.request.uri contains ".ps1"` | PowerShell script download | Fileless malware |
| `dns.qry.name matches "[a-z0-9]{20,}"` | Long random DNS names | DGA (Domain Generation Algorithm) |
| `tcp.port == 4444` | Metasploit default port | C2 communication |
| `tcp.port == 1337` | Common C2 port | C2 communication |
| `ip.dst == 185.220.101.0/24` | Known Tor exit nodes | Anonymization |
| `frame.len > 1400` | Large frames | Data exfiltration |

---

## Noise Reduction Filters

| Filter | Description |
|--------|-------------|
| `!(arp or dns or icmp)` | Remove common background noise |
| `!(broadcast)` | Remove broadcast traffic |
| `!(multicast)` | Remove multicast traffic |
| `ip` | Show only IP traffic (exclude ARP, etc.) |
| `tcp && !(tcp.port == 443)` | TCP excluding HTTPS |

---

## Compound Filters (Advanced)

| Filter | Description |
|--------|-------------|
| `ip.src == 10.0.0.5 && tcp.flags.syn == 1` | SYN packets from specific host |
| `http && ip.addr == 10.0.0.4` | HTTP traffic to/from DC |
| `dns && dns.qry.type == 1` | DNS A record queries only |
| `tcp.port == 445 && ip.src != 10.0.0.4` | SMB from non-DC source |
| `(http or ftp or telnet) && ip.src == 10.0.0.0/24` | Cleartext protocols from internal network |

---

## Useful tshark Command-Line Filters

```bash
# Capture and filter simultaneously
tshark -i 1 -f "tcp port 80" -w http_only.pcap

# Read a pcap and apply display filter
tshark -r capture.pcap -Y "dns" -T fields -e ip.src -e dns.qry.name

# Extract HTTP hosts from a capture
tshark -r capture.pcap -Y "http.request" -T fields -e http.host

# Count packets per protocol
tshark -r capture.pcap -q -z io,phs

# Show all DNS queries
tshark -r capture.pcap -Y "dns.flags.response == 0" -T fields \
    -e frame.time -e ip.src -e dns.qry.name -e dns.qry.type

# Detect SYN scans
tshark -r capture.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0" \
    -T fields -e ip.src -e ip.dst -e tcp.dstport | sort | uniq -c | sort -rn
```

---

*CyberKraft Security+ Lab 02 | Henry Jenkins | Azure VM: HenryVM*
