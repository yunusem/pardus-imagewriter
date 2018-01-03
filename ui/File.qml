import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent
        spacing: parent.height / 15

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose the disk image file")
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

        Image {
            id: diskImageIcon
            smooth: true
            mipmap: true
            scale: 1
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../images/iso.svg"
            Behavior on scale {
                PropertyAnimation {
                    easing.overshoot: 2
                    easing.type: Easing.OutBack
                    duration: 200
                }
            }
        }
    }

    DropArea {
        anchors.fill: parent
        onEntered: {
            diskImageIcon.scale = 1.2
        }

        onExited: {
            diskImageIcon.scale = 1.0
        }

        onDropped: {
            diskImageIcon.scale = 1.0
            console.log(drop.text)
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
