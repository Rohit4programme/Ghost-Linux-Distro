import sys
import os
import json
import subprocess
from PySide6.QtCore import QObject, Signal, Slot, Property

class DriverManager(QObject):
    hardware_detected = Signal(str)
    install_progress = Signal(float, str)
    install_finished = Signal(bool, str)
    diagnostic_result = Signal(str)

    def __init__(self):
        super().__init__()
        self._devices = []
        self._is_linux = sys.platform.startswith("linux")

    @Slot()
    def detect_hardware(self):
        """Runs driver detection script and reports results in JSON."""
        if not self._is_linux:
            # Mock data for testing in non-Linux (e.g. Windows)
            mock_data = {
                "gpu": {"vendor": "NVIDIA", "device": "GeForce RTX 4070 Mobile", "recommended_driver": "nvidia-dkms", "status": "Not Installed"},
                "wifi": {"vendor": "Broadcom", "device": "BCM43602 802.11ac Wireless Lan", "recommended_driver": "broadcom-wl-dkms", "status": "Installed (v6.30)"},
                "bluetooth": {"status": "Detected (bluez)", "device": "Intel Corp. Bluetooth Adapter", "recommended_driver": "bluez", "status_active": True},
                "printer": {"status": "CUPS Service Running", "devices": ["HP-LaserJet-Professional", "PDF-Printer"]}
            }
            self._devices = mock_data
            self.hardware_detected.emit(json.dumps(mock_data))
            return

        try:
            # Call custom detection helper
            result = subprocess.run(["/usr/local/bin/ghost-linux-driver-detect"], capture_output=True, text=True, check=True)
            data = json.loads(result.stdout)
            
            # Check installation status
            # GPU check
            gpu_driver = data["gpu"]["recommended_driver"]
            if gpu_driver == "nvidia-dkms":
                data["gpu"]["status"] = "Installed" if self._is_package_installed("nvidia-utils") else "Not Installed"
            else:
                data["gpu"]["status"] = "Running (Open Source Mesa)"
                
            # Wifi check
            wifi_driver = data["wifi"]["recommended_driver"]
            if wifi_driver != "linux-firmware" and wifi_driver != "unknown":
                data["wifi"]["status"] = "Installed" if self._is_package_installed(wifi_driver) else "Not Installed"
            else:
                data["wifi"]["status"] = "Running (Kernel Driver)"
                
            self._devices = data
            self.hardware_detected.emit(json.dumps(data))
        except Exception as e:
            self.hardware_detected.emit(json.dumps({"error": str(e)}))

    def _is_package_installed(self, package_name):
        res = subprocess.run(["pacman", "-Qq", package_name], capture_output=True)
        return res.returncode == 0

    @Slot(str)
    def install_driver(self, package_name):
        """Installs driver package via pacman using pkexec for privilege escalation."""
        self.install_progress.emit(10.0, "Escalating privileges...")
        
        if not self._is_linux:
            # Mock installation
            import time
            for pct, msg in [(30, "Syncing repositories..."), (60, f"Downloading {package_name}..."), (90, "Rebuilding DKMS modules..."), (100, "Installation Complete!")]:
                time.sleep(0.5)
                self.install_progress.emit(float(pct), msg)
            self.install_finished.emit(True, f"Successfully installed {package_name} (Mock). Please restart system.")
            return

        # Execute pacman via pkexec
        cmd = ["pkexec", "pacman", "-S", "--noconfirm", package_name]
        try:
            self.install_progress.emit(30.0, f"Running pacman -S {package_name}...")
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Simple line parsing for progress
            while True:
                line = process.stdout.readline()
                if not line:
                    break
                # Emit install progress messages
                self.install_progress.emit(50.0, line.strip())
                
            rc = process.wait()
            if rc == 0:
                self.install_finished.emit(True, f"Successfully installed {package_name}. Restart required.")
            else:
                err = process.stderr.read()
                self.install_finished.emit(False, f"Installation failed: {err}")
        except Exception as e:
            self.install_finished.emit(False, str(e))

    @Slot(str)
    def rollback_driver(self, package_name):
        """Rollbacks a driver using pacman cache if available."""
        self.install_progress.emit(20.0, f"Searching pacman cache for {package_name}...")
        
        if not self._is_linux:
            self.install_finished.emit(True, f"Rollback successful for {package_name} (Mock).")
            return
            
        # Command to find previous versions in /var/cache/pacman/pkg/
        cache_dir = "/var/cache/pacman/pkg/"
        pkgs = [f for f in os.listdir(cache_dir) if f.startswith(package_name) and f.endswith(".pkg.tar.zst")]
        if not pkgs:
            self.install_finished.emit(False, "No previous package versions found in pacman cache.")
            return
            
        pkgs.sort() # get sorted list
        if len(pkgs) < 2:
            self.install_finished.emit(False, "No alternative roll-back versions found.")
            return
            
        prev_version_file = os.path.join(cache_dir, pkgs[-2]) # Second to last package
        self.install_progress.emit(50.0, f"Found rollback version: {pkgs[-2]}. Installing...")
        
        cmd = ["pkexec", "pacman", "-U", "--noconfirm", prev_version_file]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode == 0:
                self.install_finished.emit(True, f"Driver rolled back to {pkgs[-2]} successfully.")
            else:
                self.install_finished.emit(False, f"Rollback failed: {res.stderr}")
        except Exception as e:
            self.install_finished.emit(False, str(e))

    @Slot()
    def run_diagnostics(self):
        """Runs driver health check diagnostic tests."""
        self.diagnostic_result.emit("Running system diagnostics...")
        
        if not self._is_linux:
            self.diagnostic_result.emit("[HEALTH CHECK] PASS\nGPU: RTX 4070 (Connected)\nWifi: BCM43602 (Active)\nDirect3D/OpenGL: Active\nNo issues found.")
            return
            
        results = []
        # Check GPU status
        nvidia_smi = subprocess.run(["which", "nvidia-smi"], capture_output=True)
        if nvidia_smi.returncode == 0:
            smi_out = subprocess.run(["nvidia-smi"], capture_output=True, text=True)
            results.append("GPU: NVIDIA driver loaded.\n" + smi_out.stdout[:300])
        else:
            results.append("GPU: Open-source Mesa / AMD / Intel drivers loaded.")
            
        # Check dmesg for driver failures
        dmesg_errs = subprocess.run(["dmesg", "--level=err,warn"], capture_output=True, text=True)
        if dmesg_errs.stdout:
            results.append("System log errors/warnings:\n" + dmesg_errs.stdout[:400])
        else:
            results.append("System logs show no critical driver crashes.")
            
        self.diagnostic_result.emit("\n\n".join(results))
