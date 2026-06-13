import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from security_manager import SecurityManager

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("SecurityCenter")
    
    engine = QQmlApplicationEngine()
    
    # Initialize backend logic and register QQml context property
    security_manager = SecurityManager()
    engine.rootContext().setContextProperty("securityManager", security_manager)
    
    # Load QML File
    qml_file = os.path.join(os.path.dirname(__file__), "SecurityCenter.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
