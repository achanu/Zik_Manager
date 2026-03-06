import QtQuick
import QtQuick.Controls
import "qrc:/elements/desktop"

Item {

    property string transitionName: "fadeTransition"

    anchors.fill: parent

    CustomButton {

         anchors.margins: 10
         anchors.top: parent.top
         anchors.horizontalCenter: parent.horizontalCenter

         text: "Demo mode"
         textColor: "white"

         onClicked: {
            zik.demoMode = true;
         }
    }

    BusyIndicator {
        id: indicator
        anchors.centerIn: parent
    }

    Text {
        anchors.top: indicator.bottom
        anchors.margins: 10
        anchors.horizontalCenter: parent.horizontalCenter

        id: loadingText
        text: qsTr("Looking for Parrot ZIK")
        color: "white"
    }
}
