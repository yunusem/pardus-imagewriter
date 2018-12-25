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
        id: clayout
        anchors.centerIn: parent
        spacing: parent.height / 15
        Layout.minimumWidth: appMain.width
        Layout.maximumWidth: appMain.width

        Label {
            id: targetTitleLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Choose the target")
        }

        ComboBox {
            id: cb
            enabled: !isBurning
            //Layout.fillWidth: true
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
                x: cb.x //- (cb.width - cbp.width) / 2
                width: cb.width * 7 / 10
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

        Image {
            id: deviceIcon
            smooth: true
            mipmap: true
            scale: 1.0
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../images/usb.svg"
        }

    }

    BusyIndicator {
        id:bi
        height: parent.height * 10 / 85
        width: height
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: clayout.top
            topMargin: clayout.spacing + targetTitleLabel.height + cb.height + 12
            //bottomMargin: parent.height / 15
        }
        onRunningChanged: {
            if (bi.running) {
                if(!isBurning) {
                    swipeView.currentIndex = 1
                    cb.enabled = false
                }

                targetDevice = ""
            } else {
                if(!isBurning) {
                    cb.enabled = true
                }
            }
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
