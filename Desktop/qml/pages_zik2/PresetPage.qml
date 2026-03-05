import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../elements/desktop"

Item {
    id: page

    CustomButton {
         id: backButton

         anchors.margins: 5
         anchors.top: parent.top
         anchors.left: parent.left

         text: "Back"
         textColor: "white"

         onClicked: {
             page.Stack.view.pop();
         }
     }


    CustomButton {
         id: fwdButton

         anchors.margins: 5
         anchors.top: parent.top
         anchors.right: parent.right

         text: "New Preset"
         textColor: "white"

         onClicked: {
             page.Stack.view.push({item: Qt.resolvedUrl("ConcertHallPage.qml"), properties: {producerMode: 1}})
         }
    }

    LabeledSwitch {
        id:smartAudioTune

        text: "Smart Audio Tune"
        textColor: "white"

        anchors.top: backButton.bottom
        anchors.left: parent.left
        anchors.margins: 5

        height: 40

        switchCheckedColor: "orange"
        switchUncheckedColor: "white"

        checked: zik.smartAudioTune == "true" ? true : false
        onCheckedChanged: {
            zik.smartAudioTune = checked ? "true" : "false"
        }
    }

    ScrollView{
        anchors.top: smartAudioTune.bottom
        anchors.left: page.left
        anchors.right: page.right
        anchors.leftMargin: 10
        anchors.topMargin: 20

        height: page.height - backButton.height - smartAudioTune.height

        ListView {
            id: presetView
            anchors.fill: parent

            spacing: 5

            model: presetModel
            delegate: RowLayout{
                property var view: parent

                LabeledSwitch {
                    property bool status : p_enabled

                    text: id +  ": " + name
                    textColor: "white"

                    switchCheckedColor: "orange"
                    switchUncheckedColor: "white"

                    height: 40

                    Component.onCompleted: checked = p_enabled
                    onCheckedChanged: {
                        if(checked != p_enabled){
                            zik.enablePreset(id, checked);
                        }
                    }

                    onStatusChanged: {
                        console.log("id " + id + "changed");
                        checked = p_enabled
                    }
                }

                Button{
                    text: "Delete"
                    onClicked: {
                        zik.deletePreset(id);
                    }

                }

            }

        }
    }

}
