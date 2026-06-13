import sys
import os
import subprocess
import threading
import json
from PySide6.QtCore import QObject, Signal, Slot

class ControlManager(QObject):
    kernels_updated = Signal(str)
    services_updated = Signal(str)
    snapshots_updated = Signal(str)
    updates_checked = Signal(str)
    action_progress = Signal(float, str)
    action_finished = Signal(bool, str)

    def __init__(self):
        super().__init__()
        self._is_linux = sys.platform.startswith("linux")

    # --- KERNEL MANAGER ---
    @Slot()
    def get_kernels(self):
        """Returns installed kernels and currently loaded kernel."""
        if not self._is_linux:
            mock_kernels = {
                "active": "6.9.3-zen1-1-zen",
                "installed": ["linux-zen", "linux-lts"],
                "available": ["linux", "linux-zen", "linux-lts", "linux-hardened"]
            }
            self.kernels_updated.emit(json.dumps(mock_kernels))
            return

        try:
            # Active Kernel
            active = subprocess.check_output(["uname", "-r"], text=True).strip()
            
            # Installed Kernels check
            installed = []
            for k in ["linux", "linux-zen", "linux-lts", "linux-hardened"]:
                res = subprocess.run(["pacman", "-Qq", k], capture_output=True)
                if res.returncode == 0:
                    installed.append(k)
                    
            kernels_data = {
                "active": active,
                "installed": installed,
                "available": ["linux", "linux-zen", "linux-lts", "linux-hardened"]
            }
            self.kernels_updated.emit(json.dumps(kernels_data))
        except Exception as e:
            self.kernels_updated.emit(json.dumps({"error": str(e)}))

    @Slot(str)
    def change_kernel(self, kernel_name):
        """Installs kernel and configures it via grub-mkconfig."""
        threading.Thread(target=self._perform_kernel_change, args=(kernel_name,)).start()

    def _perform_kernel_change(self, kernel_name):
        self.action_progress.emit(10.0, f"Escalating privileges to install {kernel_name}...")
        
        if not self._is_linux:
            import time
            time.sleep(1.0)
            self.action_progress.emit(60.0, "Regenerating GRUB boot entries...")
            time.sleep(1.0)
            self.action_finished.emit(True, f"Kernel {kernel_name} configured successfully (Mock). Restart system.")
            self.get_kernels()
            return

        try:
            # 1. Install Kernel
            self.action_progress.emit(30.0, f"Running pacman -S {kernel_name}...")
            proc = subprocess.run(["pkexec", "pacman", "-S", "--noconfirm", kernel_name, f"{kernel_name}-headers"], capture_output=True, text=True)
            if proc.returncode != 0:
                self.action_finished.emit(False, f"Kernel install failed:\n{proc.stderr}")
                return

            # 2. Re-generate GRUB
            self.action_progress.emit(70.0, "Updating bootloader configurations (grub-mkconfig)...")
            grub_proc = subprocess.run(["pkexec", "grub-mkconfig", "-o", "/boot/grub/grub.cfg"], capture_output=True, text=True)
            if grub_proc.returncode == 0:
                self.action_finished.emit(True, f"Kernel {kernel_name} installed and registered in GRUB. Please restart.")
                self.get_kernels()
            else:
                self.action_finished.emit(False, f"GRUB rebuild failed: {grub_proc.stderr}")
        except Exception as e:
            self.action_finished.emit(False, str(e))

    # --- SERVICES CONTROLLER ---
    @Slot()
    def get_services(self):
        """Scans standard systemd services status."""
        services = ["NetworkManager", "bluetooth", "cups", "sddm", "waydroid-container", "docker"]
        result = []
        
        if not self._is_linux:
            for s in services:
                result.append({"name": s, "active": s in ["NetworkManager", "bluetooth", "sddm"], "enabled": True})
            self.services_updated.emit(json.dumps(result))
            return

        for s in services:
            # Check active
            active_proc = subprocess.run(["systemctl", "is-active", s], capture_output=True, text=True)
            active = active_proc.stdout.strip() == "active"
            # Check enabled
            enabled_proc = subprocess.run(["systemctl", "is-enabled", s], capture_output=True, text=True)
            enabled = enabled_proc.stdout.strip() == "enabled"
            
            result.append({"name": s, "active": active, "enabled": enabled})
        self.services_updated.emit(json.dumps(result))

    @Slot(str, bool)
    def toggle_service(self, name, target_active):
        """Starts or stops systemd service asynchronously."""
        action = "start" if target_active else "stop"
        threading.Thread(target=self._run_service_command, args=(name, action)).start()

    def _run_service_command(self, name, action):
        if not self._is_linux:
            self.get_services()
            return
            
        subprocess.run(["pkexec", "systemctl", action, f"{name}.service"])
        self.get_services()

    # --- BACKUP MANAGER (Timeshift Wrapper) ---
    @Slot()
    def get_snapshots(self):
        """Lists timeshift snapshots."""
        if not self._is_linux:
            mock_snaps = [
                {"name": "2026-06-12_12-00-00", "type": "BTRFS", "tags": "D", "device": "/dev/sda2"},
                {"name": "2026-06-13_08-30-00", "type": "BTRFS", "tags": "H", "device": "/dev/sda2"}
            ]
            self.snapshots_updated.emit(json.dumps(mock_snaps))
            return

        try:
            # Run timeshift listing in JSON or parse terminal output
            proc = subprocess.run(["timeshift", "--list"], capture_output=True, text=True)
            # Simple text parser for timeshift terminal outputs
            snapshots = []
            lines = proc.stdout.split("\n")
            for line in lines:
                if "20" in line and "/" in line and ":" in line:
                    parts = [p.strip() for p in line.split(" ") if p.strip()]
                    if len(parts) >= 4:
                        snapshots.append({
                            "name": parts[2],
                            "type": parts[1],
                            "tags": parts[3],
                            "device": parts[0]
                        })
            self.snapshots_updated.emit(json.dumps(snapshots))
        except Exception as e:
            self.snapshots_updated.emit(json.dumps([]))

    @Slot(str)
    def create_snapshot(self, comments):
        """Creates a Btrfs Timeshift restore point."""
        threading.Thread(target=self._perform_snapshot, args=(comments,)).start()

    def _perform_snapshot(self, comments):
        self.action_progress.emit(20.0, "Creating Btrfs snapshot checkpoint...")
        
        if not self._is_linux:
            import time; time.sleep(1.5)
            self.action_finished.emit(True, "Snapshot created successfully (Mock).")
            self.get_snapshots()
            return

        cmd = ["pkexec", "timeshift", "--create", "--comments", comments, "--tags", "O"]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode == 0:
                self.action_finished.emit(True, "Snapshot created successfully.")
                self.get_snapshots()
            else:
                self.action_finished.emit(False, f"Snapshot failed:\n{res.stderr}")
        except Exception as e:
            self.action_finished.emit(False, str(e))

    # --- UNIFIED UPDATE CENTER ---
    @Slot()
    def check_updates(self):
        """Checks for package updates via checkupdates hook."""
        if not self._is_linux:
            mock_updates = [
                {"name": "linux-zen", "old_version": "6.9.2.zen1-1", "new_version": "6.9.3.zen1-1", "type": "Kernel Update"},
                {"name": "nvidia-utils", "old_version": "550.78-1", "new_version": "550.90-1", "type": "Driver Update"},
                {"name": "discord", "old_version": "0.0.54-1", "new_version": "0.0.55-1", "type": "Application Update"}
            ]
            self.updates_checked.emit(json.dumps(mock_updates))
            return

        threading.Thread(target=self._perform_check_updates).start()

    def _perform_check_updates(self):
        try:
            # Sync pacman databases in background
            subprocess.run(["pacman", "-Sy"], stdout=subprocess.DEVNULL)
            
            # Check updates
            proc = subprocess.run(["checkupdates"], capture_output=True, text=True)
            updates = []
            if proc.returncode == 0 and proc.stdout.strip():
                for line in proc.stdout.strip().split("\n"):
                    parts = [p.strip() for p in line.split(" ") if p.strip()]
                    if len(parts) >= 4: # pkgname old_ver -> new_ver
                        updates.append({
                            "name": parts[0],
                            "old_version": parts[1],
                            "new_version": parts[3],
                            "type": "System Upgrade"
                        })
            self.updates_checked.emit(json.dumps(updates))
        except Exception:
            self.updates_checked.emit("[]")

    @Slot()
    def trigger_upgrade(self):
        """Initiates full system upgrade."""
        threading.Thread(target=self._perform_upgrade).start()

    def _perform_upgrade(self):
        self.action_progress.emit(10.0, "Synchronizing pacman packages...")
        
        if not self._is_linux:
            import time; time.sleep(1.5)
            self.action_finished.emit(True, "System upgrade complete (Mock).")
            self.check_updates()
            return

        cmd = ["pkexec", "pacman", "-Syu", "--noconfirm"]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode == 0:
                self.action_finished.emit(True, "All system modules updated. Restart recommended.")
                self.check_updates()
            else:
                self.action_finished.emit(False, f"Upgrade failed: {res.stderr}")
        except Exception as e:
            self.action_finished.emit(False, str(e))

    # =====================================================================
    # --- SECURITY & FIREWALL MANAGER (UFW + Flatpak Sandbox Permissions) ---
    # =====================================================================

    firewall_status_updated = Signal(str)
    flatpak_apps_updated    = Signal(str)
    flatpak_perms_updated   = Signal(str, str)  # app_id, perms_json

    @Slot()
    def get_firewall_status(self):
        """Returns UFW status, default policy and active rules."""
        if not self._is_linux:
            mock = {
                "enabled": True,
                "default_incoming": "deny",
                "default_outgoing": "allow",
                "rules": [
                    {"port": "22",   "proto": "tcp", "action": "ALLOW", "desc": "SSH"},
                    {"port": "80",   "proto": "tcp", "action": "ALLOW", "desc": "HTTP"},
                    {"port": "443",  "proto": "tcp", "action": "ALLOW", "desc": "HTTPS"},
                    {"port": "25565","proto": "tcp", "action": "ALLOW", "desc": "Minecraft Server"},
                ]
            }
            self.firewall_status_updated.emit(json.dumps(mock))
            return

        try:
            proc = subprocess.run(["ufw", "status", "verbose"], capture_output=True, text=True)
            lines = proc.stdout.strip().split("\n")
            enabled = any("Status: active" in l for l in lines)
            default_in  = "deny"
            default_out = "allow"
            rules = []
            for line in lines:
                if "Default:" in line:
                    parts = line.lower().split()
                    if len(parts) >= 2:
                        default_in  = "deny" if "deny" in parts else "allow"
                        default_out = "allow" if "allow" in " ".join(parts) else "deny"
                # Parse rule lines: e.g. "80/tcp   ALLOW IN   Anywhere"
                if "/" in line and ("ALLOW" in line or "DENY" in line):
                    p = line.split()
                    if len(p) >= 2:
                        port_proto = p[0].split("/")
                        rules.append({
                            "port":   port_proto[0],
                            "proto":  port_proto[1] if len(port_proto) > 1 else "any",
                            "action": "ALLOW" if "ALLOW" in line else "DENY",
                            "desc":   " ".join(p[3:]) if len(p) > 3 else ""
                        })
            data = {
                "enabled": enabled,
                "default_incoming": default_in,
                "default_outgoing": default_out,
                "rules": rules
            }
            self.firewall_status_updated.emit(json.dumps(data))
        except Exception as e:
            self.firewall_status_updated.emit(json.dumps({"error": str(e)}))

    @Slot(bool)
    def toggle_ufw(self, enable):
        """Enables or disables UFW via pkexec."""
        threading.Thread(target=self._run_ufw_toggle, args=(enable,)).start()

    def _run_ufw_toggle(self, enable):
        self.action_progress.emit(20.0, "Applying firewall state change...")
        if not self._is_linux:
            import time; time.sleep(0.8)
            self.action_finished.emit(True, f"Firewall {'enabled' if enable else 'disabled'} (Mock).")
            self.get_firewall_status()
            return
        cmd = ["pkexec", "ufw", "--force", "enable" if enable else "disable"]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            success = res.returncode == 0
            self.action_finished.emit(success, res.stdout.strip() or res.stderr.strip())
            self.get_firewall_status()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot(str, str, str, str)
    def add_firewall_rule(self, port, proto, action, desc):
        """Adds a UFW rule for a given port/protocol/action."""
        threading.Thread(target=self._run_add_rule, args=(port, proto, action, desc)).start()

    def _run_add_rule(self, port, proto, action, desc):
        self.action_progress.emit(20.0, f"Adding firewall rule for port {port}/{proto}...")
        if not self._is_linux:
            import time; time.sleep(0.6)
            self.action_finished.emit(True, f"Rule {action} {port}/{proto} added (Mock).")
            self.get_firewall_status()
            return
        rule = f"{port}/{proto}"
        cmd = ["pkexec", "ufw", action.lower(), rule]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            self.action_finished.emit(res.returncode == 0, res.stdout.strip() or res.stderr.strip())
            self.get_firewall_status()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot(str, str)
    def delete_firewall_rule(self, port, proto):
        """Deletes a UFW rule."""
        threading.Thread(target=self._run_delete_rule, args=(port, proto)).start()

    def _run_delete_rule(self, port, proto):
        self.action_progress.emit(20.0, f"Removing firewall rule {port}/{proto}...")
        if not self._is_linux:
            import time; time.sleep(0.6)
            self.action_finished.emit(True, f"Rule {port}/{proto} deleted (Mock).")
            self.get_firewall_status()
            return
        cmd = ["pkexec", "ufw", "--force", "delete", "allow", f"{port}/{proto}"]
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            self.action_finished.emit(res.returncode == 0, res.stdout.strip() or res.stderr.strip())
            self.get_firewall_status()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot()
    def get_flatpak_apps(self):
        """Returns list of installed Flatpak applications."""
        if not self._is_linux:
            mock_apps = [
                {"id": "com.discordapp.Discord",        "name": "Discord",     "version": "0.0.55"},
                {"id": "org.mozilla.firefox",           "name": "Firefox",     "version": "127.0"},
                {"id": "com.spotify.Client",            "name": "Spotify",     "version": "1.2.3"},
                {"id": "org.videolan.VLC",              "name": "VLC",         "version": "3.0.21"},
                {"id": "com.valvesoftware.Steam",       "name": "Steam",       "version": "1.0.0.78"},
            ]
            self.flatpak_apps_updated.emit(json.dumps(mock_apps))
            return
        try:
            proc = subprocess.run(
                ["flatpak", "list", "--columns=application,name,version"],
                capture_output=True, text=True
            )
            apps = []
            for line in proc.stdout.strip().split("\n")[1:]:
                parts = line.split("\t")
                if len(parts) >= 3:
                    apps.append({"id": parts[0].strip(), "name": parts[1].strip(), "version": parts[2].strip()})
            self.flatpak_apps_updated.emit(json.dumps(apps))
        except Exception as e:
            self.flatpak_apps_updated.emit(json.dumps([]))

    @Slot(str)
    def get_sandbox_permissions(self, app_id):
        """Returns sandbox override permissions for a Flatpak app."""
        if not self._is_linux:
            mock_perms = {
                "network":      True,
                "filesystem":   "home",
                "ipc":          True,
                "pulseaudio":   True,
                "x11":          True,
                "wayland":      True,
                "dri":          True,
            }
            self.flatpak_perms_updated.emit(app_id, json.dumps(mock_perms))
            return
        try:
            proc = subprocess.run(
                ["flatpak", "override", "--show", app_id],
                capture_output=True, text=True
            )
            # Parse INI-like output
            perms = {}
            for line in proc.stdout.strip().split("\n"):
                if "=" in line:
                    k, _, v = line.partition("=")
                    perms[k.strip()] = v.strip()
            self.flatpak_perms_updated.emit(app_id, json.dumps(perms))
        except Exception as e:
            self.flatpak_perms_updated.emit(app_id, json.dumps({}))

    @Slot(str, str, bool)
    def set_sandbox_permission(self, app_id, permission, enabled):
        """Overrides a specific Flatpak permission for an app (user-level, no sudo needed)."""
        threading.Thread(target=self._apply_flatpak_perm, args=(app_id, permission, enabled)).start()

    def _apply_flatpak_perm(self, app_id, permission, enabled):
        if not self._is_linux:
            import time; time.sleep(0.4)
            self.action_finished.emit(True, f"Permission '{permission}' {'granted' if enabled else 'revoked'} for {app_id} (Mock).")
            return
        # Map permission key -> flatpak override flag
        perm_flags = {
            "network":    "--share=network"  if enabled else "--unshare=network",
            "filesystem": "--filesystem=home" if enabled else "--nofilesystem=home",
            "ipc":        "--share=ipc"      if enabled else "--unshare=ipc",
            "dri":        "--device=dri"     if enabled else "--nodevice=dri",
        }
        flag = perm_flags.get(permission)
        if not flag:
            self.action_finished.emit(False, f"Unknown permission key: {permission}")
            return
        try:
            proc = subprocess.run(["flatpak", "override", "--user", flag, app_id], capture_output=True, text=True)
            self.action_finished.emit(proc.returncode == 0, proc.stdout.strip() or proc.stderr.strip())
            self.get_sandbox_permissions(app_id)
        except Exception as e:
            self.action_finished.emit(False, str(e))

    # =====================================================
    # --- CLOUD SYNCHRONIZATION MANAGER (rclone wrapper) ---
    # =====================================================

    remotes_updated  = Signal(str)
    sync_log_updated = Signal(str)

    @Slot()
    def get_rclone_remotes(self):
        """Lists configured rclone remote cloud storage targets."""
        if not self._is_linux:
            mock_remotes = [
                {"name": "gdrive",    "type": "Google Drive",  "path": "gdrive:/Documents",    "last_sync": "2026-06-13 08:00"},
                {"name": "onedrive",  "type": "Microsoft OneDrive", "path": "onedrive:/Backups", "last_sync": "2026-06-12 22:00"},
            ]
            self.remotes_updated.emit(json.dumps(mock_remotes))
            return
        try:
            proc = subprocess.run(["rclone", "listremotes"], capture_output=True, text=True)
            names = [r.rstrip(":") for r in proc.stdout.strip().split("\n") if r.strip()]
            remotes = []
            for name in names:
                # Query type from config
                cfg = subprocess.run(["rclone", "config", "show", name], capture_output=True, text=True)
                rtype = "Unknown"
                for line in cfg.stdout.split("\n"):
                    if line.strip().startswith("type"):
                        rtype = line.split("=")[-1].strip().replace("_", " ").title()
                remotes.append({"name": name, "type": rtype, "path": f"{name}:/", "last_sync": "Never"})
            self.remotes_updated.emit(json.dumps(remotes))
        except Exception as e:
            self.remotes_updated.emit(json.dumps({"error": str(e)}))

    @Slot(str, str)
    def sync_remote(self, remote_name, local_path):
        """Triggers an rclone sync from remote to local path asynchronously."""
        threading.Thread(target=self._perform_sync, args=(remote_name, local_path)).start()

    def _perform_sync(self, remote_name, local_path):
        self.action_progress.emit(10.0, f"Connecting to {remote_name}...")
        self.sync_log_updated.emit(f"Starting sync: {remote_name} -> {local_path}\n")

        if not self._is_linux:
            import time
            steps = [
                (30.0,  f"Scanning remote {remote_name} for changes..."),
                (60.0,  "Downloading changed files..."),
                (90.0,  "Verifying file integrity..."),
                (100.0, "Sync complete!"),
            ]
            for pct, msg in steps:
                time.sleep(0.7)
                self.action_progress.emit(pct, msg)
                self.sync_log_updated.emit(f"[{pct:.0f}%] {msg}\n")
            self.action_finished.emit(True, f"Cloud sync from {remote_name} completed successfully (Mock).")
            return

        local_path = os.path.expanduser(local_path)
        os.makedirs(local_path, exist_ok=True)
        cmd = ["rclone", "sync", f"{remote_name}:/", local_path, "--progress", "--stats-one-line"]
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            for line in proc.stdout:
                self.sync_log_updated.emit(line)
            proc.wait()
            if proc.returncode == 0:
                self.action_finished.emit(True, f"Sync from {remote_name} completed.")
            else:
                self.action_finished.emit(False, f"Sync failed with code {proc.returncode}.")
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot(str)
    def delete_remote(self, remote_name):
        """Removes an rclone remote configuration."""
        if not self._is_linux:
            self.action_finished.emit(True, f"Remote '{remote_name}' removed (Mock).")
            self.get_rclone_remotes()
            return
        try:
            proc = subprocess.run(["rclone", "config", "delete", remote_name], capture_output=True, text=True)
            self.action_finished.emit(proc.returncode == 0, proc.stdout.strip() or f"Remote {remote_name} deleted.")
            self.get_rclone_remotes()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    # ===================================================
    # --- WAYDROID ANDROID SUBSYSTEM CONFIGURATOR ---
    # ===================================================

    waydroid_status_updated = Signal(str)
    waydroid_apps_updated   = Signal(str)
    waydroid_log_updated    = Signal(str)

    @Slot()
    def get_waydroid_status(self):
        """Returns waydroid session status, Android version, and running state."""
        if not self._is_linux:
            mock = {
                "running":         True,
                "android_version": "Android 11 (LineageOS 18.1)",
                "image_type":      "GAPPS",
                "ip":              "192.168.240.112",
                "session_mode":    "wayland",
                "cpu_cores":       4,
                "ram_mb":          2048,
            }
            self.waydroid_status_updated.emit(json.dumps(mock))
            return
        try:
            proc = subprocess.run(["waydroid", "status"], capture_output=True, text=True)
            data = {
                "running":         "Session" in proc.stdout and "RUNNING" in proc.stdout,
                "android_version": "Android 11",
                "image_type":      "VANILLA",
                "ip":              "192.168.240.112",
                "session_mode":    "wayland",
                "cpu_cores":       4,
                "ram_mb":          2048,
            }
            # Try to parse vendor info
            for line in proc.stdout.split("\n"):
                if "Android" in line:
                    data["android_version"] = line.strip()
            self.waydroid_status_updated.emit(json.dumps(data))
        except Exception as e:
            self.waydroid_status_updated.emit(json.dumps({"error": str(e)}))

    @Slot(bool)
    def toggle_waydroid_session(self, active):
        """Starts or stops the Waydroid Android container session."""
        threading.Thread(target=self._toggle_waydroid, args=(active,)).start()

    def _toggle_waydroid(self, active):
        action = "start" if active else "stop"
        self.action_progress.emit(15.0, f"{'Starting' if active else 'Stopping'} Android container...")
        if not self._is_linux:
            import time; time.sleep(1.2)
            self.action_finished.emit(True, f"Waydroid session {'started' if active else 'stopped'} (Mock).")
            self.get_waydroid_status()
            return
        try:
            cmd = ["pkexec", "waydroid", "session", action]
            proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            self.action_finished.emit(proc.returncode == 0, proc.stdout.strip() or proc.stderr.strip())
            self.get_waydroid_status()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot(str)
    def install_apk(self, apk_path):
        """Installs an APK file into the Waydroid Android container."""
        threading.Thread(target=self._install_apk, args=(apk_path,)).start()

    def _install_apk(self, apk_path):
        self.action_progress.emit(10.0, f"Installing APK: {os.path.basename(apk_path)}...")
        if not self._is_linux:
            import time; time.sleep(1.5)
            self.action_finished.emit(True, f"APK '{os.path.basename(apk_path)}' installed successfully (Mock).")
            return
        try:
            proc = subprocess.run(
                ["waydroid", "app", "install", apk_path],
                capture_output=True, text=True, timeout=60
            )
            if proc.returncode == 0:
                self.action_finished.emit(True, f"APK installed: {os.path.basename(apk_path)}")
            else:
                self.action_finished.emit(False, f"APK install failed:\n{proc.stderr}")
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot()
    def get_waydroid_apps(self):
        """Returns list of installed Android apps inside Waydroid."""
        if not self._is_linux:
            mock_apps = [
                {"package": "com.google.android.gms",    "name": "Google Play Services"},
                {"package": "com.android.vending",        "name": "Google Play Store"},
                {"package": "com.whatsapp",               "name": "WhatsApp"},
                {"package": "com.instagram.android",      "name": "Instagram"},
                {"package": "org.telegram.messenger",     "name": "Telegram"},
            ]
            self.waydroid_apps_updated.emit(json.dumps(mock_apps))
            return
        try:
            proc = subprocess.run(
                ["waydroid", "app", "list"],
                capture_output=True, text=True
            )
            apps = []
            for line in proc.stdout.strip().split("\n"):
                if ":" in line:
                    pkg, _, name = line.partition(":")
                    apps.append({"package": pkg.strip(), "name": name.strip()})
            self.waydroid_apps_updated.emit(json.dumps(apps))
        except Exception as e:
            self.waydroid_apps_updated.emit(json.dumps([]))

    @Slot(str)
    def uninstall_android_app(self, package_name):
        """Removes an Android app from the Waydroid container."""
        threading.Thread(target=self._uninstall_android_app, args=(package_name,)).start()

    def _uninstall_android_app(self, package_name):
        self.action_progress.emit(15.0, f"Uninstalling {package_name}...")
        if not self._is_linux:
            import time; time.sleep(0.8)
            self.action_finished.emit(True, f"App '{package_name}' uninstalled (Mock).")
            self.get_waydroid_apps()
            return
        try:
            proc = subprocess.run(
                ["waydroid", "app", "remove", package_name],
                capture_output=True, text=True
            )
            self.action_finished.emit(proc.returncode == 0, proc.stdout.strip() or proc.stderr.strip())
            self.get_waydroid_apps()
        except Exception as e:
            self.action_finished.emit(False, str(e))

    @Slot(int, int)
    def configure_waydroid_resources(self, cpu_cores, ram_mb):
        """Writes Waydroid resource limits to config."""
        if not self._is_linux:
            self.action_finished.emit(True, f"Waydroid resources set to {cpu_cores} CPUs / {ram_mb} MB RAM (Mock).")
            return
        config_path = os.path.expanduser("~/.local/share/waydroid/waydroid.cfg")
        try:
            lines = []
            if os.path.exists(config_path):
                with open(config_path) as f:
                    lines = f.readlines()
            # Update or append cpu/ram entries
            updated = {l.split("=")[0].strip(): False for l in lines if "=" in l}
            new_lines = []
            for line in lines:
                key = line.split("=")[0].strip()
                if key == "cpu_count":
                    new_lines.append(f"cpu_count = {cpu_cores}\n")
                elif key == "ram_count":
                    new_lines.append(f"ram_count = {ram_mb}\n")
                else:
                    new_lines.append(line)
            if "cpu_count" not in [l.split("=")[0].strip() for l in lines]:
                new_lines.append(f"cpu_count = {cpu_cores}\n")
            if "ram_count" not in [l.split("=")[0].strip() for l in lines]:
                new_lines.append(f"ram_count = {ram_mb}\n")
            with open(config_path, "w") as f:
                f.writelines(new_lines)
            self.action_finished.emit(True, f"Resources updated: {cpu_cores} CPUs, {ram_mb} MB RAM. Restart Waydroid to apply.")
        except Exception as e:
            self.action_finished.emit(False, str(e))

