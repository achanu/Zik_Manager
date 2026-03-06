import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item{

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
}
