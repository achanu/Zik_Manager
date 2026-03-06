import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item{
    height: area.contentHeight + description.contentHeight + 2

    property string text: ""
    property string label: ""
    property bool readOnly: false

    TextArea {
        id: area
        enabled: true
        width: parent.width
        height: contentHeight
        readOnly: parent.readOnly

        text: parent.text

        color: "white"
        selectionColor: "transparent"
        selectedTextColor: "white"
        background: null
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        font: description.font

        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    }
    Text {
        id: description
        anchors.top: area.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        text: parent.label
        color: "white"
        opacity: 0.5
    }
}
