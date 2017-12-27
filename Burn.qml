import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent

    signal progressValueChanged
    signal burningProcessFinished

    property int maxValue : 1
    property int previousIndex : 0

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
                source: "iso.svg"
                width: appMain.width / 10
                height: width
                smooth: true
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: fileName
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
                source: "usb.svg"
                width: appMain.width / 10
                height: width
                smooth: true
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: targetDevice
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Button {
            id: btnBurn
            enabled: fileName != "" && targetDevice != ""
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Burn")
            visible: ! isBurning
            onClicked: {                
                isBurning = true
                pb.value = 0.00
                previousIndex = target.comboBoxIndex
                appMain.title = "%"+ pb.value * 100
                helper.writeToDevice(target.comboBoxIndex)
                maxValue = helper.maximumProgressValue()
            }
        }

        ProgressBar {
            id: pb
            anchors.horizontalCenter: parent.horizontalCenter
            value: 0.01
            visible: isBurning
            Label {
                id: pbText
                anchors {
                    top: parent.bottom
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                text: ""
            }
        }
    }

    onProgressValueChanged: {
        var currentVal = helper.progress * 0.01
        var maxVal = maxValue * 1.0
        pb.value = currentVal * 100 / maxVal
        appMain.title = "%"+ (pb.value * 100).toFixed(2)
        pbText.text = (currentVal * 100).toFixed(0) + "MB"
    }
    onBurningProcessFinished: {
        appMain.title = qsTr("Pardus Image Writer")
        target.comboBoxIndex = previousIndex
        console.log("Burning is finished")
    }
}
