import QtQuick

import QtQuick.Controls

Item{
    id: equaSlider


    property real gain: 0
    property int frequency
    property real q: 1


    Slider {
        id: gainSlider

        anchors.top: parent.top
        anchors.left: parent.left
        orientation: Qt.Vertical

        from: -12.0
        to: 12.0
        stepSize: 0.25

        onPressedChanged: {
            if(!pressed){
                equaSlider.gain = value;
            }
        }

        background: Rectangle {
            id: gainGroove
            implicitWidth: 250
            implicitHeight: 4
            color: "black"
            radius: 12
        }
        handle: Rectangle {
            id: gainHandle
            x: gainSlider.leftPadding + gainSlider.availableWidth / 2 - width / 2
            y: gainSlider.topPadding + gainSlider.visualPosition * gainSlider.availableHeight - height / 2
            color: gainSlider.pressed ? "white" : "lightgray"
            border.color: "black"
            border.width: 2
            width: 17
            height: 28
            radius: 6
            Text{
                anchors.bottom: parent.top
                text: gainSlider.value.toFixed(2) + "dB"
                font.pixelSize: 13
            }
        }
    }

    Slider {
        id: qSlider

        z: 1

        anchors.top: parent.top
        x: gainSlider.x + 10

        orientation: Qt.Vertical

        from: 0.4
        to: 4.0
        stepSize: 0.1

        value: 1

        onPressedChanged: {
            if(!pressed){
                equaSlider.q = value;
            }
        }

        background: Rectangle {
            implicitWidth: 250
            implicitHeight: 4
            color: "black"
            radius: 12
            opacity: 0
        }
        handle: Rectangle {
            x: qSlider.leftPadding + qSlider.availableWidth / 2 - width / 2
            y: qSlider.topPadding + qSlider.visualPosition * qSlider.availableHeight - height / 2
            color: qSlider.pressed ? "white" : "lightgray"
            border.color: "black"
            border.width: 2
            width: 17
            height: 25
            radius: 6
            Text{
                anchors.top: parent.bottom
                text: "q:" + String(qSlider.value).substring(0,3)
                font.pixelSize: 13
            }
        }
    }

}
