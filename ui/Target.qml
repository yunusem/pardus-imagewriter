import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

Item {
    anchors.fill: parent
    signal scheduleStarted
    signal dlChanged
    property alias targetDeviceName : cb.currentText
    property alias comboBoxIndex : cb.currentIndex

    ColumnLayout {
        id: clTarget
        anchors.centerIn: parent
        spacing: parent.height / 10

        Layout.minimumWidth: appMain.width
        Layout.maximumWidth: appMain.width



        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose the target")
        }

        Image {
            id: deviceIcon
            smooth: true
            mipmap: true
            scale: 0.8
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../images/usb.svg"
        }

        ComboBox {
            id: cb
            enabled: !isBurning
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            scale: 0.7
            spacing: 6
            background: themeBtn.background
            anchors.horizontalCenter: parent.horizontalCenter
            model: cbItems
            currentIndex: 0
            onActivated: {
                targetDevice = targetDeviceName
            }
            popup: Popup {
                id: cbp
                scale: 0.6
                y: cb.height - 1
                x: cb.x - (cb.width - cbp.width) / 2
                width: cb.width * 8 / 10
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: cb.popup.visible ? cb.delegateModel : null
                    currentIndex: cb.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    color: "#2c2c2c"
                }
            }

        }
    }

    BusyIndicator {
        id:bi
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: parent.height / 4 + 5
        }

    }

    onScheduleStarted: {
        bi.running = true
    }

    onDlChanged: {
        bi.running = false
        cb.currentIndex = 0
    }

    Button {
        id: themeBtn
        visible: false
    }

    Component.onCompleted: {
        bi.running = false
    }
}
