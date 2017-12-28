import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent

    signal progressValueChanged
    signal burningProcessFinished
    signal startBurning

    property real maxValue : 1
    property int previousIndex : 0

    Item {
        id: p1
        anchors.fill: parent
        opacity: isBurning ? 0 : 1.0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: parent.height / 10

            Row {
                id: fileRow
                spacing: 5
                visible: fileName != ""
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: fileIcon
                    source: "../images/iso.svg"
                    width: appMain.width / 10
                    height: width
                    smooth: true
                    antialiasing: true
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: fileName
                    font.pointSize: 9
                    fontSizeMode: Text.HorizontalFit
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Row {
                id: targetRow
                spacing: 5
                visible: targetDevice != ""
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: targetIcon
                    source: "../images/usb.svg"
                    width: appMain.width / 10
                    height: width
                    smooth: true
                }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: targetDevice
                    font.pointSize: 9
                    fontSizeMode: Text.HorizontalFit
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Button {
                id: btnBurn
                enabled: fileName != "" && targetDevice != ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Start")
                visible: true
                onClicked: {
                    requestForBurn = true
                    dialog.topic = qsTr("This operation will erase all\nthe data in your device.\nAre you sure to continue ?")
                    dialog.open()
                }
            }
        }
        Behavior on opacity {
            PropertyAnimation {
                duration: 400
            }
        }
    }

    ProgressBarCircle {
        id: pb
        anchors.centerIn: parent
        width: parent.width * 2 / 3
        height: parent.width * 2 / 3
        colorCircle: "#ffcb08"
        colorBackground: "#111111"
        thickness: 10
        opacity: isBurning ? 1 : 0
        visible: isBurning ? true : false
        Behavior on opacity {
            PropertyAnimation {
                duration: 1000
            }
        }
    }

    onStartBurning: {
        previousIndex = target.comboBoxIndex
        appMain.title = "%"+ pb.value * 100
        helper.writeToDevice(target.comboBoxIndex)
        pb.value = 0
        pb.maximumValue = helper.maximumProgressValue()
        isBurning = true
    }

    onProgressValueChanged: {
        pb.value = helper.progress
        var currentVal = helper.progress * 0.01
        var maxVal = pb.maximumValue
        currentVal = currentVal * 100 / maxVal
        appMain.title = "%"+ (currentVal * 100).toFixed(2)
    }
    onBurningProcessFinished: {
        appMain.title = qsTr("Pardus Image Writer")
        target.comboBoxIndex = previousIndex
        dialog.topic = qsTr("Writing process is Finished !")
        dialog.showButtons = false
        dialog.open()
    }
}
