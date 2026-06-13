import sys
import os
import json
import subprocess
from PySide6.QtCore import QObject, Signal, Slot, Property

class SecurityManager(QObject):
    tool_detected = Signal(str)
    scan_progress = Signal(float, str)
    scan_finished = Signal(bool, str)
    tool_result = Signal(str)

    def __init__(self):
        super().__init__()
        self._tools = []
        self._is_linux = sys.platform.startswith("linux")
        
        # Security tool categories
        self._categories = {
            "Information Gathering": ["nmap", "netcat", "whois", "masscan", "zmap", "angry-ip-scanner", "wireshark", "tcpdump", "traceroute", "mtr", "dnsutils", "bind-tools", "dnsenum", "dnsrecon", "sublist3r", "theharvester", "recon-ng", "shodan-cli"],
            "Vulnerability Analysis": ["nikto", "sqlmap", "wpscan", "nuclei", "nessus", "openvas", "greenbone-security-assistant", "skipfish", "w3af"],
            "Web Application Analysis": ["burpsuite", "owasp-zap", "dirb", "gobuster", "ffuf", "wfuzz", "whatweb", "wpscan", "joomscan", "cmsmap"],
            "Password Attacks": ["hashcat", "john", "hydra", "medusa", "crunch", "cewl", "maskprocessor", "hashcat-utils", "rainbowcrack", "ophcrack", "chntpw"],
            "Wireless Attacks": ["aircrack-ng", "kismet", "reaver", "wifite", "cowpatty", "asleap", "pyrit"],
            "Exploitation Tools": ["metasploit", "exploitdb", "searchsploit", "setoolkit", "social-engineer-toolkit", "beef", "responder", "empire", "covenant"],
            "Sniffing & Spoofing": ["ettercap", "mitmproxy", "bettercap", "yersinia", "tcpkill", "hping3", "scapy", "ngrep", "dsniff"],
            "Post-Exploitation": ["mimikatz", "creddump", "laZagne", "hasher", "passing-the-hash"],
            "Forensics": ["autopsy", "sleuthkit", "volatility", "bulk-extractor", "binwalk", "foremost", "guymager", "testdisk", "photoRec"],
            "Reverse Engineering": ["ghidra", "radare2", "ida-free", "binary-ninja", "cutter", "gdb", "objdump", "strace", "ltrace"],
            "Reporting Tools": ["dradis", "keepnote", "faraday", "magic-tree", "casefile"],
            "Hardware Hacking": ["arduino", "firmware-mod-kit", "flashrom", "openocd"],
            "Network Analysis": ["ntopng", "nagios", "zabbix", "prometheus", "grafana", "elasticsearch", "logstash", "kibana"],
            "Cryptography": ["gnupg", "openssl", "truecrypt", "veracrypt", "cryptsetup", "steghide", "outguess"]
        }

    @Slot()
    def detect_tools(self):
        """Scans for installed security tools and reports results in JSON."""
        detected_tools = {}
        
        for category, tools in self._categories.items():
            detected_tools[category] = []
            for tool in tools:
                if self._is_tool_installed(tool):
                    detected_tools[category].append({"name": tool, "installed": True})
                else:
                    detected_tools[category].append({"name": tool, "installed": False})
        
        self._tools = detected_tools
        self.tool_detected.emit(json.dumps(detected_tools))

    def _is_tool_installed(self, tool_name):
        """Check if a tool is installed on the system."""
        try:
            if self._is_linux:
                result = subprocess.run(["which", tool_name], capture_output=True)
                return result.returncode == 0
            else:
                # Mock for non-Linux systems
                return True
        except Exception:
            return False

    @Slot(str)
    def run_tool(self, tool_name):
        """Launch a security tool."""
        if not self._is_linux:
            self.tool_result.emit(f"Tool '{tool_name}' would be launched (Mock mode)")
            return
        
        try:
            subprocess.Popen([tool_name])
            self.tool_result.emit(f"Successfully launched {tool_name}")
        except Exception as e:
            self.tool_result.emit(f"Failed to launch {tool_name}: {str(e)}")

    @Slot(str, str)
    def run_scan(self, tool_name, target):
        """Run a security scan with a specific tool."""
        self.scan_progress.emit(10.0, f"Initializing {tool_name} scan...")
        
        if not self._is_linux:
            # Mock scan
            import time
            for pct, msg in [(30, "Scanning target..."), (60, "Analyzing results..."), (90, "Generating report..."), (100, "Scan complete!")]:
                time.sleep(0.5)
                self.scan_progress.emit(float(pct), msg)
            self.scan_finished.emit(True, f"Scan completed for {target} using {tool_name}")
            return
        
        try:
            # Execute tool
            cmd = [tool_name, target]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            self.scan_progress.emit(50.0, f"Running {tool_name} on {target}...")
            
            while True:
                line = process.stdout.readline()
                if not line:
                    break
                self.scan_progress.emit(70.0, line.strip())
                
            rc = process.wait()
            if rc == 0:
                self.scan_finished.emit(True, f"Scan completed successfully for {target}")
            else:
                err = process.stderr.read()
                self.scan_finished.emit(False, f"Scan failed: {err}")
        except Exception as e:
            self.scan_finished.emit(False, str(e))

    @Slot(str)
    def install_tool(self, tool_name):
        """Install a security tool via pacman."""
        self.scan_progress.emit(10.0, f"Preparing to install {tool_name}...")
        
        if not self._is_linux:
            self.scan_finished.emit(True, f"Tool '{tool_name}' would be installed (Mock mode)")
            return
        
        try:
            self.scan_progress.emit(30.0, f"Running pacman -S {tool_name}...")
            cmd = ["pkexec", "pacman", "-S", "--noconfirm", tool_name]
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            self.scan_progress.emit(50.0, "Downloading and installing package...")
            
            while True:
                line = process.stdout.readline()
                if not line:
                    break
                self.scan_progress.emit(70.0, line.strip())
                
            rc = process.wait()
            if rc == 0:
                self.scan_finished.emit(True, f"Successfully installed {tool_name}")
                self.detect_tools()  # Refresh tool list
            else:
                err = process.stderr.read()
                self.scan_finished.emit(False, f"Installation failed: {err}")
        except Exception as e:
            self.scan_finished.emit(False, str(e))

    @Slot(str)
    def get_tool_info(self, tool_name):
        """Get information about a specific tool."""
        tool_info = {
            "name": tool_name,
            "description": self._get_tool_description(tool_name),
            "category": self._get_tool_category(tool_name)
        }
        self.tool_result.emit(json.dumps(tool_info))

    def _get_tool_description(self, tool_name):
        """Return a brief description for common tools."""
        descriptions = {
            "nmap": "Network Mapper - Network discovery and security auditing tool",
            "wireshark": "Network protocol analyzer for network troubleshooting and analysis",
            "burpsuite": "Web application security testing tool",
            "metasploit": "Penetration testing framework for developing and executing exploit code",
            "hashcat": "Advanced password recovery utility",
            "aircrack-ng": "WiFi security auditing tools suite",
            "sqlmap": "Automated SQL injection and database takeover tool",
            "nikto": "Web server scanner that performs comprehensive tests",
            "john": "John the Ripper - Fast password cracker",
            "hydra": "Parallel login cracker supporting many protocols",
            "ettercap": "Comprehensive suite for man-in-the-middle attacks",
            "ghidra": "Software reverse engineering framework",
            "radare2": "Reverse engineering framework and toolset",
            "autopsy": "Digital forensics platform",
            "volatility": "Memory forensics framework",
            "binwalk": "Firmware analysis tool",
            "gobuster": "Directory/file & DNS busting tool",
            "ffuf": "Fuzzing tool for web applications",
            "mitmproxy": "Interactive HTTPS proxy",
            "bettercap": "Swiss army knife for network attacks and monitoring"
        }
        return descriptions.get(tool_name, "Security tool for penetration testing and security auditing")

    def _get_tool_category(self, tool_name):
        """Find which category a tool belongs to."""
        for category, tools in self._categories.items():
            if tool_name in tools:
                return category
        return "Other"
