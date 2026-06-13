import sys
import os
import subprocess
import threading
import time
from PySide6.QtCore import QObject, Signal, Slot, QTimer

class GamingManager(QObject):
    telemetry_updated = Signal(float, float, float, float) # cpu_load, gpu_temp, ram_usage, fps
    mode_changed = Signal(str)

    def __init__(self):
        super().__init__()
        self._is_linux = sys.platform.startswith("linux")
        self._active_mode = "Balanced"
        
        # Setup telemetry timer (every 1 second)
        self.telemetry_timer = QTimer(self)
        self.telemetry_timer.timeout.connect(self._fetch_telemetry)
        self.telemetry_timer.start(1000)

    def _fetch_telemetry(self):
        """Reads hardware sensors and emits real-time stats."""
        if not self._is_linux:
            # Emit mock telemetry values (with slight variations)
            import random
            cpu = 15.0 + random.uniform(-2, 5)
            gpu = 45.0 + random.uniform(-1, 2)
            ram = 38.2 + random.uniform(-0.5, 0.5)
            fps = 144.0 if self._active_mode in ["Gaming", "Maximum"] else 60.0
            self.telemetry_updated.emit(cpu, gpu, ram, fps)
            return

        try:
            # 1. CPU Load
            cpu_cmd = "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'"
            cpu_load = float(subprocess.check_output(cpu_cmd, shell=True).strip())
            
            # 2. RAM Load
            ram_cmd = "free | grep Mem | awk '{print $3/$2 * 100.0}'"
            ram_usage = float(subprocess.check_output(ram_cmd, shell=True).strip())
            
            # 3. GPU Temp
            gpu_temp = 40.0
            # Try NVIDIA first
            if os.path.exists("/usr/bin/nvidia-smi"):
                gpu_out = subprocess.check_output(["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader"], text=True)
                gpu_temp = float(gpu_out.strip())
            else:
                # AMD/Intel hwmon
                hwmon_paths = ["/sys/class/drm/card0/device/hwmon/hwmon1/temp1_input", "/sys/class/drm/card0/device/hwmon/hwmon0/temp1_input"]
                for p in hwmon_paths:
                    if os.path.exists(p):
                        with open(p, "r") as f:
                            gpu_temp = float(f.read().strip()) / 1000.0
                            break
                            
            # 4. FPS (Estimator or MangoHud proxy value)
            fps = 0.0
            self.telemetry_updated.emit(cpu_load, gpu_temp, ram_usage, fps)
        except Exception:
            self.telemetry_updated.emit(0.0, 0.0, 0.0, 0.0)

    @Slot(str)
    def set_performance_mode(self, mode):
        """Modifies kernel CPU governors and GPU power envelopes based on selected mode."""
        self._active_mode = mode
        
        if not self._is_linux:
            self.mode_changed.emit(mode)
            return

        # Power configurations mapping
        # Battery Saver: governor=powersave, nvidia power cap lowered
        # Balanced: governor=powersave (normal dynamic)
        # Gaming: governor=performance, GPU power cap raised, gamemode enabled
        # Maximum: governor=performance, fans full speed (if supported), max power limits
        
        gov = "powersave"
        if mode in ["Gaming", "Maximum"]:
            gov = "performance"
            
        # 1. Update CPU Governor via cpupower
        threading.Thread(target=self._run_power_command, args=(gov, mode)).start()

    def _run_power_command(self, governor, mode):
        try:
            # Set CPU governor (requires privilege escalation)
            subprocess.run(["pkexec", "cpupower", "frequency-set", "-g", governor], stdout=subprocess.DEVNULL)
            
            # Adjust GPU Power targets if NVIDIA
            if os.path.exists("/usr/bin/nvidia-smi"):
                if mode == "Battery Saver":
                    subprocess.run(["pkexec", "nvidia-smi", "-pl", "100"], stdout=subprocess.DEVNULL) # Limit to 100W
                elif mode in ["Gaming", "Maximum"]:
                    # Query max power limit
                    subprocess.run(["pkexec", "nvidia-smi", "-pm", "1"], stdout=subprocess.DEVNULL) # Persistence mode
                    subprocess.run(["pkexec", "nvidia-smi", "-pl", "250"], stdout=subprocess.DEVNULL) # Raise cap
            
            self.mode_changed.emit(mode)
        except Exception as e:
            print(f"Failed to modify performance profiles: {str(e)}")

    @Slot(str)
    def launch_game_client(self, client):
        """Launches game launcher platforms under gamemoderun if enabled."""
        if not self._is_linux:
            print(f"[GAMING CENTER] Mock launch: {client}")
            return

        # Check if gamemoderun is available
        has_gamemode = subprocess.run(["which", "gamemoded"], capture_output=True).returncode == 0
        cmd = [client]
        if has_gamemode:
            cmd = ["gamemoderun", client]
            
        try:
            subprocess.Popen(cmd)
        except Exception as e:
            print(f"Launch failed: {str(e)}")

    @Slot(bool)
    def toggle_mangohud(self, enabled):
        """Writes default MangoHud system override configuration."""
        hud_dir = os.path.expanduser("~/.config/MangoHud")
        os.makedirs(hud_dir, exist_ok=True)
        conf_file = os.path.join(hud_dir, "MangoHud.conf")
        
        if enabled:
            config = (
                "legacy_layout=0\n"
                "horizontal\n"
                "hud_no_margin\n"
                "font_size=16\n"
                "table_columns=3\n"
                "gpu_text=GPU\n"
                "gpu_stats\n"
                "gpu_temp\n"
                "cpu_text=CPU\n"
                "cpu_stats\n"
                "cpu_temp\n"
                "fps\n"
                "frame_timing=0\n"
                "background_alpha=0.4\n"
            )
            with open(conf_file, "w") as f:
                f.write(config)
        else:
            if os.path.exists(conf_file):
                os.remove(conf_file)
