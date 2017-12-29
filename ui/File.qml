import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent
        spacing: parent.height / 10

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose the disk image file")
        }

        Image {
            width: 100
            smooth: true

            anchors.horizontalCenter: parent.horizontalCenter
            source: "../images/iso.svg"
        }

        Button {
            id: btn
            scale: 0.8
            enabled: !isBurning
            anchors.horizontalCenter: parent.horizontalCenter
            text: "+"
            onClicked: {                
                fd.open()
            }
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: {
            fileLabel.text = drop.text
        }
    }

    FileDialog {
        id: fd
        title: qsTr("Please choose the disk image")
        folder: helper.downloadsFolderPath()
        nameFilters: [qsTr("Disk images") + " (*.iso *.bin *.img)"]
        onAccepted: {
            var path = fd.fileUrl.toString();
            if (helper.preProcessImageFile(path)) {
                filePath = path
                fileName = helper.fileNameFromPath(filePath)
                btn.text = fileName
            }
        }
        onRejected: {
            btn.text = fileName != "" ? fileName : "+"
        }
        visible: false
        Component.onCompleted: {
            fd.close()
        }
    }
}
