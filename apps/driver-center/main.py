import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from driver_manager import DriverManager

def main():
    # Set styling parameters or env overrides if necessary
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("DriverCenter")
    
    engine = QQmlApplicationEngine()
    
    # Instantiate backend manager and expose it to QML environment
    driver_manager = DriverManager()
    engine.rootContext().setContextProperty("driverManager", driver_manager)
    
    # Load QML File
    qml_file = os.path.join(os.path.dirname(__file__), "DriverCenter.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
