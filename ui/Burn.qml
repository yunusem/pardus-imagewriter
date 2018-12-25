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
    signal warnUserCalled

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
            spacing: parent.height / 12

            Item {
                id: fileRow
                height: p1.height / 10
                width: p1.width * 5 / 6
                anchors.horizontalCenter: parent.horizontalCenter
                visible: fileName != ""

                MouseArea {
                    id: fileRowMa
                    enabled: !isBurning
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        swipeView.currentIndex = 0
                    }
                    cursorShape: Qt.PointingHandCursor
                    ToolTip.text: qsTr("Click to return disk image selection")
                    ToolTip.delay: 1000
                    ToolTip.visible: containsMouse
                    ToolTip.timeout: 3000
                }


                Image {
                    id: fileIcon
                    height: parent.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../images/iso.svg"
                    sourceSize {
                        width: fileIcon.width
                        height: fileIcon.height
                    }
                    smooth: true
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                }

                Label {
                    id: fileLabel
                    text: fileName
                    color: fileRowMa.containsMouse ? "#ffcb08" : "#eeeeee"
                    font.pointSize: parent.height / 4 > 0 ? parent.height / 4 : 10
                    elide: Text.ElideMiddle
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: fileIcon.right
                        right: parent.right
                        rightMargin: 5
                    }

                }

            }

            Item {
                id: targetRow
                height: p1.height / 10
                width: p1.width * 4 / 5
                anchors.horizontalCenter: parent.horizontalCenter
                visible: targetDevice != ""

                MouseArea {
                    id: targetRowMa
                    enabled: !isBurning
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        swipeView.currentIndex = 1
                    }
                    cursorShape: Qt.PointingHandCursor
                    ToolTip.text: qsTr("Click to return target selection")
                    ToolTip.delay: 1000
                    ToolTip.visible: containsMouse
                    ToolTip.timeout: 3000
                }

                Image {
                    id: targetIcon
                    height: parent.height
                    width: height
                    source: "../images/usb.svg"
                    sourceSize {
                        width: targetIcon.width
                        height: targetIcon.height
                    }
                    smooth: false
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                }

                Label {
                    id: targetLabel
                    text: targetDevice
                    color: targetRowMa.containsMouse ? "#ffcb08" : "#eeeeee"
                    font.pointSize: parent.height / 4 > 0 ? parent.height / 4 : 10
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: targetIcon.right
                        right: parent.right
                        margins: 5
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
                hoverEnabled: true
                ToolTip.text: qsTr("Click to start burning")
                ToolTip.delay: 1500
                ToolTip.visible: hovered
                ToolTip.timeout: 3000
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
                visible: isBurning
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
        helper.notifySystem(dialog.topic, qsTr("You can now remove the device:")
                            + " <b>" + targetDevice.split("(")[0]+"</b>" )
        dialog.open()
    }
    onBurningProcessCancelled: {
        requestForCancel = false
        appMain.title = qsTr("Pardus Image Writer")
        target.comboBoxIndex = previousIndex
    }

    onWarnUserCalled: {
        dialog.topic = helper.messageFromBackend
        dialog.showButtons = false
        dialog.open()
    }
}
