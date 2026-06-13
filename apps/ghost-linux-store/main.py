import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from store_manager import StoreManager

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("Ghost-LinuxStore")
    
    engine = QQmlApplicationEngine()
    
    # Instantiate backend and register context properties
    store_manager = StoreManager()
    engine.rootContext().setContextProperty("storeManager", store_manager)
    
    # Load QML File
    qml_file = os.path.join(os.path.dirname(__file__), "GhostStore.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
