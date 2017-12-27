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
            text: qsTr("Choose the image file")
        }

        Image {
            width: 100
            smooth: true

            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/iso.svg"
        }

        Button {
            id: btn
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("+")
            onClicked: {
                fd.visible = true
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
        title: "Please choose a file"
        folder: shortcuts.home
        nameFilters: ["Image files (*.iso *.img)"]
        onAccepted: {
            var path = fd.fileUrl.toString();
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"");
            var cleanPath = decodeURIComponent(path);
            cleanPath = "/" + cleanPath
            if (helper.preProcessImageFile(cleanPath)) {
                filePath = cleanPath
                fileName = helper.fileNameFromPath(filePath)
                btn.text = fileName
            }
        }
        onRejected: {
            btn.text = fileName != "" ? fileName : "+"
        }
        visible: false
    }
}
