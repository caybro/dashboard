/** (c) caybro */

import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

ToolButton {
    id: root

    property alias color: dlg.color

    signal accepted(color color)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: root.color
    }

    ColorDialog {
        id: dlg
        visible: false
        showAlphaChannel: true
        title: qsTr("Pick color")
        modality: Qt.ApplicationModal
        onAccepted: root.accepted(color)
    }

    onClicked: dlg.visible = !dlg.visible
}
