# Ghost-Linux Security Tools Documentation

Ghost-Linux includes comprehensive security tools from Kali Linux, providing a complete penetration testing and security auditing platform. This document covers all available security tools organized by category.

## Table of Contents

1. [Information Gathering / Reconnaissance](#information-gathering--reconnaissance)
2. [Vulnerability Analysis](#vulnerability-analysis)
3. [Web Application Analysis](#web-application-analysis)
4. [Password Attacks](#password-attacks)
5. [Wireless Attacks](#wireless-attacks)
6. [Exploitation Tools](#exploitation-tools)
7. [Sniffing & Spoofing](#sniffing--spoofing)
8. [Post-Exploitation](#post-exploitation)
9. [Forensics](#forensics)
10. [Reverse Engineering](#reverse-engineering)
11. [Reporting Tools](#reporting-tools)
12. [Hardware Hacking](#hardware-hacking)
13. [Network Analysis](#network-analysis)
14. [Cryptography](#cryptography)

---

## Information Gathering / Reconnaissance

### Nmap
**Network Mapper** - Network discovery and security auditing tool
```bash
nmap -sS -O target_ip          # SYN scan with OS detection
nmap -sV target_ip             # Service version detection
nmap -A target_ip              # Aggressive scan
nmap -p- target_ip             # Scan all 65535 ports
```

### Wireshark
**Network Protocol Analyzer** - Deep packet inspection and network troubleshooting
- GUI-based network protocol analyzer
- Capture and analyze network traffic in real-time
- Supports hundreds of protocols

### Masscan
**High-speed port scanner** - Can scan entire internet in under 6 minutes
```bash
masscan 192.168.1.0/24 -p80,443,22 --rate=10000
```

### Zmap
**Internet-scale network scanner** - Designed for rapid network surveys
```bash
zmap -p 443 -o results.csv 192.168.0.0/16
```

### Angry IP Scanner
**Fast IP address and port scanner** - Cross-platform network scanner
- GUI-based scanner for Windows, Linux, and Mac
- Detects alive hosts and open ports

### TheHarvester
**OSINT tool for gathering emails, subdomains, hosts, employee names**
```bash
theharvester -d target.com -l 500 -b google
```

### Recon-ng
**Full-featured Web Reconnaissance framework**
- Modular reconnaissance framework
- Built-in database for storing findings
- Extensible with custom modules

### Shodan CLI
**Command-line interface for Shodan search engine**
```bash
shodan search --limit 10 apache
```

---

## Vulnerability Analysis

### Nikto
**Web server scanner** - Performs comprehensive tests against web servers
```bash
nikto -h http://target.com
```

### SQLMap
**Automated SQL injection tool** - Database takeover and penetration testing
```bash
sqlmap -u "http://target.com/page?id=1" --dbs
sqlmap -u "http://target.com/page?id=1" --dump
```

### Nuclei
**Fast vulnerability scanner** - Template-based vulnerability scanner
```bash
nuclei -u https://target.com -t cves/
```

### OpenVAS
**Vulnerability scanner** - Full-featured vulnerability scanning and management
- Web-based interface for vulnerability management
- Supports SCAP and CVE checks

### Greenbone Security Assistant
**Web interface for OpenVAS** - Vulnerability management dashboard
- Centralized vulnerability management
- Report generation and tracking

---

## Web Application Analysis

### Burp Suite
**Web application security testing tool**
- Proxy for intercepting HTTP requests
- Scanner for automated vulnerability detection
- Intruder for brute-force attacks
- Repeater for manual request manipulation

### OWASP ZAP
**Web application security scanner** - Free and open source web app scanner
- Automated scanner with passive and active modes
- API for security testing
- Extensible with add-ons

### Gobuster
**Directory/file & DNS busting tool**
```bash
gobuster dir -u https://target.com -w wordlist.txt
gobuster dns -d target.com -w subdomains.txt
```

### FFUF
**Fuzzing tool for web applications**
```bash
ffuf -u https://target.com/FUZZ -w wordlist.txt
```

### WhatWeb
**Web technology identification tool**
```bash
whatweb target.com
```

---

## Password Attacks

### Hashcat
**Advanced password recovery utility**
```bash
hashcat -m 0 hash.txt wordlist.txt          # MD5
hashcat -m 1000 hash.txt wordlist.txt       # NTLM
hashcat -m 3200 hash.txt wordlist.txt      # bcrypt
```

### John the Ripper
**Fast password cracker**
```bash
john --wordlist=wordlist.txt hash.txt
john --show hash.txt
```

### Hydra
**Parallel login cracker** - Supports many protocols
```bash
hydra -l user -P wordlist.txt ssh://target.com
hydra -l admin -P pass.txt ftp://target.com
```

### Medusa
**Parallel network login auditor**
```bash
medusa -h target.com -u admin -P pass.txt -M ssh
```

### Crunch
**Password wordlist generator**
```bash
crunch 8 8 abcdefghijklmnopqrstuvwxyz -o wordlist.txt
```

---

## Wireless Attacks

### Aircrack-ng
**WiFi security auditing tools suite**
```bash
airmon-ng start wlan0
airodump-ng wlan0mon
aireplay-ng -0 10 -a BSSID wlan0mon
aircrack-ng -w wordlist.txt capture.cap
```

### Kismet
**Wireless network detector, sniffer, and intrusion detection system**
- 802.11 layer2 wireless network detector
- Passively captures packets
- GPS tracking support

### Reaver
**WPS PIN brute force attack tool**
```bash
reaver -i wlan0mon -b BSSID -vv
```

### Wifite
**Automated wireless attack tool**
```bash
wifite --all
```

---

## Exploitation Tools

### Metasploit
**Penetration testing framework**
```bash
msfconsole
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS target_ip
exploit
```

### Searchsploit
**Exploit-DB search tool**
```bash
searchsploit apache 2.4
searchsploit -t windows
```

### SET (Social Engineer Toolkit)
**Social engineering penetration testing framework**
```bash
setoolkit
```

### BeEF
**Browser Exploitation Framework**
- Hook web browsers
- Execute commands in browser context
- Phishing and social engineering

### Responder
**LLMNR, NBT-NS, and MDNS poisoner**
```bash
responder -I eth0
```

---

## Sniffing & Spoofing

### Ettercap
**Comprehensive suite for man-in-the-middle attacks**
```bash
ettercap -T -M arp:remote /target_ip/ /gateway_ip/
```

### Mitmproxy
**Interactive HTTPS proxy**
```bash
mitmproxy
mitmweb
```

### Bettercap
**Swiss army knife for network attacks and monitoring**
```bash
bettercap -caplet http.proxy
```

### Hping3
**Custom TCP/IP packet generator and analyzer**
```bash
hping3 -S -p 80 target_ip
```

### Scapy
**Python packet manipulation library**
```python
from scapy.all import *
packet = IP(dst="target_ip")/TCP(dport=80)
send(packet)
```

---

## Post-Exploitation

### Mimikatz
**Windows credential extractor**
- Extract plaintext passwords from memory
- Kerberos ticket manipulation
- Pass-the-hash attacks

### LaZagne
**Password recovery tool**
- Extracts passwords from browsers, email clients, etc.
- Supports Windows, Linux, and macOS

---

## Forensics

### Autopsy
**Digital forensics platform**
- Disk image analysis
- Timeline analysis
- Keyword search
- File carving

### Sleuth Kit
**File system forensic analysis tools**
```bash
fls -r image.dd
fsstat image.dd
```

### Volatility
**Memory forensics framework**
```bash
volatility -f memory.dmp imageinfo
volatility -f memory.dmp pslist
```

### Binwalk
**Firmware analysis tool**
```bash
binwalk firmware.bin
binwalk -e firmware.bin
```

### TestDisk
**Data recovery utility**
```bash
testdisk /dev/sdb
```

---

## Reverse Engineering

### Ghidra
**Software reverse engineering framework**
- Developed by NSA
- Disassembler and decompiler
- Supports multiple architectures

### Radare2
**Reverse engineering framework and toolset**
```bash
r2 binary
aaa
pdf
```

### Cutter
**GUI for Radare2**
- Modern interface for reverse engineering
- Visual control flow graphs

### GDB
**GNU Debugger**
```bash
gdb ./binary
break main
run
```

---

## Reporting Tools

### Dradis
**Collaboration and reporting framework**
- Centralized reporting platform
- Team collaboration features
- Template-based report generation

### Faraday
**Collaborative penetration testing IDE**
- Real-time collaboration
- Plugin architecture
- Report generation

---

## Network Analysis

### Ntopng
**Network traffic probe**
- Real-time network traffic monitoring
- Flow analysis
- Host behavior profiling

### Nagios
**Network monitoring system**
- Host and service monitoring
- Alerting and notification
- Performance data collection

### Zabbix
**Enterprise monitoring solution**
- Distributed monitoring
- Agent-based and agentless monitoring
- Auto-discovery

### Prometheus
**Time-series database and monitoring system**
- Metrics collection
- Alerting
- Grafana integration

---

## Cryptography

### GnuPG
**GNU Privacy Guard**
```bash
gpg --gen-key
gpg --encrypt -r recipient file.txt
gpg --decrypt file.txt.gpg
```

### OpenSSL
**Cryptography toolkit**
```bash
openssl genrsa -out private.key 2048
openssl req -new -key private.key -out request.csr
```

### VeraCrypt
**Disk encryption software**
- Cross-platform disk encryption
- Hidden volumes
- Plausible deniability

### Steghide
**Steganography tool**
```bash
steghide embed -f cover.jpg -ef secret.txt -p password
steghide extract -sf cover.jpg -p password
```

---

## Using Security Center

Ghost-Linux includes a **Security Center** application that provides a unified interface for managing all security tools:

1. **Launch Security Center**: `ghost-linux-security-center` or from the application menu
2. **Browse Tools**: Organized by category with installation status
3. **Install Tools**: One-click installation via pacman
4. **Launch Tools**: Direct launch from the interface
5. **Get Information**: Tool descriptions and usage info

### JARVIS AI Integration

JARVIS AI can help with security tools:
- "Scan network with nmap"
- "Launch wireshark"
- "Open security center"
- "Run security scan on 192.168.1.1"
- "Install burpsuite"

---

## Legal and Ethical Use

**IMPORTANT**: These tools are powerful and should only be used on systems you own or have explicit permission to test. Unauthorized use of these tools is illegal and unethical.

- Always obtain proper authorization before testing
- Follow responsible disclosure practices
- Use tools for educational and defensive purposes
- Respect privacy and data protection laws

---

## Getting Help

- **Security Center**: Built-in tool information and descriptions
- **Man Pages**: `man <tool_name>` for detailed documentation
- **Tool Websites**: Official documentation for each tool
- **Ghost-Linux Community**: Community forums and support channels

---

## Additional Resources

- [Kali Linux Tools Documentation](https://www.kali.org/tools/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [Penetration Testing Framework](http://www.vulnerabilityassessment.co.uk/Penetration%20Test.html)
- [Ghost-Linux Documentation](../README.md)
