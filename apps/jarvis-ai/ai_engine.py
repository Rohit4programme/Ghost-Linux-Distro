import sys
import os
import json
import subprocess
import threading
import time
from PySide6.QtCore import QObject, Signal, Slot

class JarvisEngine(QObject):
    state_changed = Signal(str) # "idle", "listening", "thinking", "speaking"
    chat_message = Signal(str, str) # sender ("User" / "Jarvis"), text
    voice_wave = Signal(float) # Float amplitude for visualizer

    def __init__(self):
        super().__init__()
        self._state = "idle"
        self._speech_enabled = False
        self._gemini_api_key = os.environ.get("GEMINI_API_KEY", "")
        self._ollama_url = "http://localhost:11434/api/generate"
        
        # Initialize Speech components in a separate thread if libraries exist
        threading.Thread(target=self._init_speech, daemon=True).start()

    def _init_speech(self):
        try:
            import speech_recognition as sr
            import pyttsx3
            self._recognizer = sr.Recognizer()
            self._tts = pyttsx3.init()
            self._speech_enabled = True
        except ImportError:
            self._speech_enabled = False

    @Slot(str)
    def send_chat_message(self, message):
        """Sends chat query and updates state."""
        if not message.strip():
            return
            
        self.chat_message.emit("User", message)
        self.set_state("thinking")
        
        threading.Thread(target=self._query_ai, args=(message,)).start()

    def set_state(self, state):
        self._state = state
        self.state_changed.emit(state)

    def _query_ai(self, prompt):
        # 1. System Instruction Context
        system_context = (
            "You are JARVIS AI, the built-in assistant for Ghost-Linux, a next-generation Arch Linux distribution. "
            "You have system execution capabilities. If the user asks to open an app, install software, check updates, "
            "or change system settings, output your answer inside a JSON block with schema: "
            "{\"response\": \"<text response>\", \"intent\": \"<intent_type>\", \"params\": {\"<param_key>\": \"<val>\"}} "
            "Supported intents: open_app, install_package, change_volume, run_diagnostics, start_waydroid, search_files, run_security_scan, launch_security_tool, install_security_tool. "
            "Otherwise, respond in markdown text."
        )
        
        response_text = ""
        intent_data = None
        
        # 2. Query Model (Local Ollama first fallback to Mock/Simple rules)
        # In a real environment, we call requests.post to self._ollama_url or google.generativeai
        try:
            # Let's perform a simple regex check for mock execution first,
            # or if Ollama is available, call it.
            # Here we provide a mock AI engine logic that is extremely responsive and demonstrates system intents:
            time.sleep(1.0) # Simulate thinking
            
            p_lower = prompt.lower()
            if "open" in p_lower or "launch" in p_lower:
                app = "dolphin"
                if "steam" in p_lower: app = "steam"
                elif "discord" in p_lower: app = "discord"
                elif "code" in p_lower or "vs code" in p_lower: app = "code"
                elif "store" in p_lower: app = "ghost-linuxstore"
                
                intent_data = {"response": f"Opening {app} for you.", "intent": "open_app", "params": {"app_name": app}}
            
            elif "install" in p_lower:
                pkg = "firefox"
                if "steam" in p_lower: pkg = "steam"
                elif "discord" in p_lower: pkg = "discord"
                intent_data = {"response": f"Initiating installation of package '{pkg}'.", "intent": "install_package", "params": {"package_name": pkg}}
                
            elif "diagnostics" in p_lower or "health" in p_lower:
                intent_data = {"response": "Running full hardware diagnostic check.", "intent": "run_diagnostics", "params": {}}
                
            elif "android" in p_lower or "waydroid" in p_lower:
                intent_data = {"response": "Starting Android subsystem (Waydroid).", "intent": "start_waydroid", "params": {}}
            
            elif "scan" in p_lower and ("network" in p_lower or "port" in p_lower or "security" in p_lower):
                target = "192.168.1.1"  # Default target
                if "nmap" in p_lower:
                    intent_data = {"response": f"Running network scan with nmap on {target}", "intent": "run_security_scan", "params": {"tool": "nmap", "target": target}}
                else:
                    intent_data = {"response": f"Running security scan on {target}", "intent": "run_security_scan", "params": {"tool": "nmap", "target": target}}
            
            elif "security" in p_lower and ("center" in p_lower or "tool" in p_lower):
                intent_data = {"response": "Opening Security Center for tool management.", "intent": "launch_security_tool", "params": {"app_name": "ghost-linux-security-center"}}
            
            elif any(tool in p_lower for tool in ["burpsuite", "wireshark", "metasploit", "hashcat", "hydra", "sqlmap", "nikto"]):
                tool = next((t for t in ["burpsuite", "wireshark", "metasploit", "hashcat", "hydra", "sqlmap", "nikto"] if t in p_lower), "nmap")
                intent_data = {"response": f"Launching {tool} security tool.", "intent": "launch_security_tool", "params": {"app_name": tool}}
                
            else:
                # Standard response
                if "who are you" in p_lower:
                    response_text = "I am JARVIS AI, your virtual assistant built into Ghost-Linux. I can manage your desktop, install packages, optimize games, and write code for you!"
                elif "code" in p_lower or "write" in p_lower:
                    response_text = "Here is a Python function to generate Btrfs snapshots:\n```python\nimport subprocess\ndef create_snapshot(source, dest):\n    subprocess.run(['btrfs', 'subvolume', 'snapshot', source, dest])\n```"
                else:
                    response_text = f"I'm here to help with Ghost-Linux. You queried: '{prompt}'. I can also help with security tools like nmap, wireshark, burpsuite, metasploit, hashcat, and more. Ask me to scan networks, launch security tools, or open the Security Center!"

        except Exception as e:
            response_text = f"Error communicating with AI core: {str(e)}"

        if intent_data:
            response_text = intent_data["response"]
            # Trigger command execute
            self._execute_intent(intent_data["intent"], intent_data["params"])

        self.chat_message.emit("Jarvis", response_text)
        self.set_state("speaking")
        self._speak(response_text)
        self.set_state("idle")

    def _speak(self, text):
        if not self._speech_enabled:
            # Simulate speech wave animation
            for _ in range(5):
                self.voice_wave.emit(0.8)
                time.sleep(0.1)
                self.voice_wave.emit(0.2)
                time.sleep(0.1)
            self.voice_wave.emit(0.0)
            return

        try:
            self._tts.say(text)
            self._tts.runAndWait()
        except:
            pass

    def _execute_intent(self, intent, params):
        """Processes intent and executes matching OS command."""
        try:
            if intent == "open_app":
                app_name = params.get("app_name")
                if sys.platform.startswith("linux"):
                    subprocess.Popen(["gtk-launch", app_name])
                else:
                    # Windows mock launcher
                    os.system(f"start {app_name}")
            elif intent == "install_package":
                pkg = params.get("package_name")
                # Simulate package install or run command
                print(f"[JARVIS SYSTEM COMMAND] Installing package: {pkg}")
            elif intent == "start_waydroid":
                if sys.platform.startswith("linux"):
                    subprocess.run(["pkexec", "waydroid", "session", "start"])
            elif intent == "run_diagnostics":
                # Trigger driver diagnostic
                print("[JARVIS SYSTEM COMMAND] Running system diagnostics.")
            elif intent == "run_security_scan":
                tool = params.get("tool", "nmap")
                target = params.get("target", "127.0.0.1")
                if sys.platform.startswith("linux"):
                    print(f"[JARVIS SYSTEM COMMAND] Running {tool} scan on {target}")
                    subprocess.Popen([tool, target])
                else:
                    print(f"[JARVIS SYSTEM COMMAND] Would run {tool} scan on {target} (Mock)")
            elif intent == "launch_security_tool":
                app_name = params.get("app_name")
                if sys.platform.startswith("linux"):
                    subprocess.Popen(["gtk-launch", app_name])
                else:
                    print(f"[JARVIS SYSTEM COMMAND] Would launch {app_name} (Mock)")
            elif intent == "install_security_tool":
                tool = params.get("tool_name")
                print(f"[JARVIS SYSTEM COMMAND] Installing security tool: {tool}")
        except Exception as e:
            print(f"Failed to execute intent: {str(e)}")

    @Slot()
    def toggle_voice_mode(self):
        """Enables wake-word detection and listing state."""
        if self._state == "listening":
            self.set_state("idle")
            return
            
        self.set_state("listening")
        threading.Thread(target=self._listen_voice).start()

    def _listen_voice(self):
        if not self._speech_enabled:
            time.sleep(2.0)
            self.send_chat_message("Hey Jarvis, scan my drivers")
            return

        try:
            import speech_recognition as sr
            with sr.Microphone() as source:
                self._recognizer.adjust_for_ambient_noise(source)
                audio = self._recognizer.listen(source, timeout=5)
                self.set_state("thinking")
                text = self._recognizer.recognize_google(audio)
                self.send_chat_message(text)
        except Exception as e:
            self.chat_message.emit("Jarvis", f"Speech recognition error: {str(e)}")
            self.set_state("idle")
