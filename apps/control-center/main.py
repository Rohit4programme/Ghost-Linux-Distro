import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from control_manager import ControlManager

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("ControlCenter")
    
    engine = QQmlApplicationEngine()
    
    # Initialize backend configurations and load properties to QML Context
    control_manager = ControlManager()
    engine.rootContext().setContextProperty("controlManager", control_manager)
    
    # Load QML file
    qml_file = os.path.join(os.path.dirname(__file__), "ControlCenter.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
