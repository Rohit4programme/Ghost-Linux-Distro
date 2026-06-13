import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from gaming_manager import GamingManager

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("GamingCenter")
    
    engine = QQmlApplicationEngine()
    
    # Initialize backend logic and register QQml context property
    gaming_manager = GamingManager()
    engine.rootContext().setContextProperty("gamingManager", gaming_manager)
    
    # Load QML File
    qml_file = os.path.join(os.path.dirname(__file__), "GamingCenter.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
