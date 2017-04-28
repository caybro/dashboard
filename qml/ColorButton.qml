import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

ToolButton {
    id: root

    property alias color: dlg.color

    signal accepted(color color)

    background: Rectangle {
        implicitHeight: 30
        implicitWidth: implicitHeight
        color: root.color
    }

    ColorDialog {
        id: dlg
        visible: false
        showAlphaChannel: true
        title: qsTr("Select color")
        modality: Qt.WindowModal
        onAccepted: root.accepted(color)
    }

    onClicked: dlg.visible = !dlg.visible
}
