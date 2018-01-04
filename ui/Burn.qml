import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.0

Item {
    anchors.fill: parent

    signal progressValueChanged
    signal burningProcessFinished
    signal burningProcessCancelled
    signal startBurning

    property real maxValue : 1
    property int previousIndex : 0

    Item {
        id: p1
        anchors.fill: parent
        opacity: isBurning ? 0.0 : 1.0

        Behavior on opacity {
            PropertyAnimation {
                duration: 800
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: parent.height / 10

            Item {
                id: fileRow
                height: fileIcon.height
                width: appMain.width - 10
                visible: fileName != ""

                MouseArea {
                    enabled: !isBurning
                    anchors.fill: parent
                    onClicked: {
                        swipeView.currentIndex = 0
                    }
                }

                Row {
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image {
                        id: fileIcon
                        source: "../images/iso.svg"
                        width: appMain.width / 10
                        height: width
                        smooth: true
                        mipmap: true
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
            }

            Item {
                id: targetRow
                height: targetIcon.height
                width: appMain.width - 10
                visible: targetDevice != ""

                MouseArea {
                    enabled: !isBurning
                    anchors.fill: parent
                    onClicked: {
                        swipeView.currentIndex = 1
                    }
                }

                Row {
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image {
                        id: targetIcon
                        source: "../images/usb.svg"
                        width: appMain.width / 10
                        height: width
                        smooth: true
                        mipmap: true
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
            }

            Button {
                id: btnBurn
                highlighted: true
                Material.accent: "#2c2c2c"
                enabled: fileName != "" && targetDevice != ""
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Start")
                visible: true
                onClicked: {
                    if (helper.getImageSize() <= helper.getSelectedDeviceSize(target.comboBoxIndex)) {
                        requestForBurn = true
                        dialog.topic = qsTr("This operation will erase all\nthe data in your target device.\n\nAre you sure to continue ?")
                        dialog.open()
                    } else {
                        dialog.topic = qsTr("Writing process could not start.\n\nThe disk image size is greater\nthan the target device size.")
                        dialog.showButtons = false
                        dialog.open()
                    }
                }
            }
        }
    }

    Item {
        id: p2

        anchors.fill: parent
        opacity: p1.opacity == 0.0 ? 1.0 : 0.0

        Behavior on opacity {
            PropertyAnimation {
                duration: 800
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: parent.width / 10
            ProgressBarCircle {
                id: pb
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                width: p2.width * 2 / 3
                height: p2.width * 2 / 3
                colorCircle: "#ffcb08"
                colorBackground: "#111111"
                thickness: 10
            }

            Button {
                id: btnCancel
                highlighted: true
                Material.accent: Material.Red
                Material.theme: Material.Light
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                text: requestForCancel ? qsTr("CANCELLING...") : qsTr("Cancel")
                visible: true
                enabled: !requestForCancel
                onClicked: {
                    requestForCancel = true
                    dialog.topic = qsTr("Are you sure to cancel ?")
                    dialog.open()
                }
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
    onBurningProcessCancelled: {
        requestForCancel = false
        appMain.title = qsTr("Pardus Image Writer")
        target.comboBoxIndex = previousIndex
    }
}
