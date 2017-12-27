import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent

    signal dlChanged
    property alias targetDeviceName : cb.currentText
    property alias comboBoxIndex : cb.currentIndex

    ColumnLayout {
        anchors.centerIn: parent
        spacing: parent.height / 10

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose the target")
        }

        Image {
            width: 100
            smooth: true

            anchors.horizontalCenter: parent.horizontalCenter
            source: "../images/usb.svg"
        }


        ComboBox {
            id: cb
            scale: 0.6
            spacing: 6
            anchors.horizontalCenter: parent.horizontalCenter
            model: cbItems
            currentIndex: 0
            onActivated: {
                targetDevice = targetDeviceName
            }
        }
    }
    onDlChanged: {
        cb.currentIndex = 0
    }
}
