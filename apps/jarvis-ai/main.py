import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from ai_engine import JarvisEngine

def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Ghost-Linux")
    app.setApplicationName("JarvisAI")
    
    engine = QQmlApplicationEngine()
    
    # Initialize Jarvis Engine and register it to the QML context properties
    jarvis_engine = JarvisEngine()
    engine.rootContext().setContextProperty("jarvisEngine", jarvis_engine)
    
    # Load QML File
    qml_file = os.path.join(os.path.dirname(__file__), "JarvisPanel.qml")
    engine.load(qml_file)
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
