import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import piw.helper 1.0

ApplicationWindow {
    id: appMain
    visible: true
    maximumWidth: 300
    maximumHeight: 400
    width: 300
    height: 400
    flags: Qt.FramelessWindowHint
    title: qsTr("Pardus Image Writer")

    property bool requestForBurn : false
    property bool requestForQuit : false

    property bool isBurning : false
    property string filePath : ""
    property string fileName : ""
    property string targetDevice: ""

    signal dialogAccepted
    signal dialogRejected

    Helper {
        id: helper
        onTerminateCalled: {
            dialog.showButtons = false
            dialog.topic = qsTr("Something is trying to kill me!!!")
            dialog.open()
        }
        onDeviceListChanged: {
            cbItems.clear();
            for (var i = 0; i < helper.devices.length; i++) {
                cbItems.append({"text": helper.devices[i].split(" - ")[1]});
            }
            target.dlChanged()
            targetDevice = target.targetDeviceName
        }
        onProgressChanged: {
            burn.progressValueChanged()
        }
        onBurningFinished: {
            isBurning = false
            burn.burningProcessFinished()
        }
    }

    ListModel {
        id:cbItems
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: 0
        Page {

            width: appMain.width
            height: appMain.height
            File{
                id: file

            }
        }
        Page {
            width: appMain.width
            height: appMain.height
            Target{
                id: target
            }
        }

        Page {
            width: appMain.width
            height: appMain.height
            Burn {
                id: burn
            }
        }
        onCurrentIndexChanged: {
            if(isBurning) {
                currentIndex = 2
            }
        }
    }

    PageIndicator {
        id: indicator
        interactive: true
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        anchors.bottom: swipeView.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        onCurrentIndexChanged: {
            swipeView.currentIndex = indicator.currentIndex
        }

    }

    Button {
        id: nextBtn
        scale: 0.7
        background: Rectangle {
            color: "#2c2c2c"
        }
        visible: swipeView.currentIndex == 2 ? false : true
        anchors {
            bottom: parent.bottom
            right: parent.right
        }
        text: qsTr("Next")
        onClicked: {
            swipeView.currentIndex = swipeView.currentIndex + 1
        }
    }

    Button {
        id: backBtn
        scale: 0.7
        background: Rectangle {
            color: "#2c2c2c"
        }
        enabled: ! isBurning
        visible: swipeView.currentIndex == 0 ? false : true
        anchors {
            bottom: parent.bottom
            left: parent.left
        }
        text: qsTr("Back")
        onClicked: {
            swipeView.currentIndex = swipeView.currentIndex - 1
        }
    }

    Button {
        id: closeBtn
        scale: 0.8
        background: Rectangle {
            color: "#2c2c2c"
        }
        enabled: ! isBurning
        visible: true
        anchors {
            top: parent.top
            topMargin: -5
            right: parent.right
        }
        text: "X"
        onClicked: {
            requestForQuit = true
            dialog.topic = qsTr("Are you sure to exit ?")
            dialog.open()
        }
    }

    Button {
        id: minimizeBtn
        scale: 1.2
        background: Rectangle {
            color: "#2c2c2c"
        }
        enabled: true
        visible: true
        anchors {
            top: parent.top
            topMargin: -5
            right: parent.right
            rightMargin: 20
        }
        text: "-"
        onClicked: {
            appMain.showMinimized()
        }
    }

    Rectangle {
        id: dock
        color: "transparent"
        height: appMain.height / 8
        anchors {
            top: parent.top
            left: parent.left
            right: minimizeBtn.left
        }
        MouseArea {
            anchors.fill: parent
            property int cposx: 1
            property int cposy: 1
            onPressed: {
                var cpos = Qt.point(mouse.x,mouse.y);
                cposx = cpos.x
                cposy = cpos.y
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x - cposx, mouse.y - cposy);
                appMain.x += delta.x;
                appMain.y += delta.y;

            }
        }
    }

    Popup {
        id: dialog
        width: appMain.width
        height: dialog.width / 2
        modal: true
        closePolicy: Popup.CloseOnPressOutside
        y: appMain.height / 2 - dialog.height / 2

        property string topic : ""
        property bool showButtons : true
        signal accepted
        signal rejected

        Label {
            anchors {
                top: parent.top
                topMargin: parent.height / 10
                horizontalCenter: parent.horizontalCenter
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: dialog.topic
        }

        Row {
            id: btnRow
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: parent.width / 10
            Button {
                id: yesBtn
                visible: dialog.showButtons
                text: qsTr("Yes")
                background: Rectangle {
                    color: "#2c2c2c"
                }
                onClicked: {
                    dialog.accepted()
                }
            }

            Button {
                id: noBtn
                visible: dialog.showButtons
                text: qsTr("No")
                background: Rectangle {
                    color: "#2c2c2c"
                }

                onClicked: {
                    dialog.rejected()
                }
            }
        }

        onAccepted: {
            appMain.dialogAccepted()
            dialog.topic = ""
            close()
        }
        onRejected: {
            appMain.dialogRejected()
            dialog.topic = ""
            close()
        }
        onClosed: {
            dialog.showButtons = true
            dialog.topic = ""
        }

        Timer {
            interval: 3000
            running: !dialog.showButtons
            onTriggered: {
                dialog.close()
            }
        }

    }

    onDialogAccepted: {
        if (requestForQuit) {
            Qt.quit()
        }
        if (requestForBurn) {
            burn.startBurning()
            requestForBurn = false
        }

    }
    onDialogRejected: {
        requestForQuit = false
        requestForBurn = false
    }

    Component.onCompleted: {
        for (var i = 0; i < helper.devices.length; i++) {
            cbItems.append({"text": helper.devices[i].split(" - ")[1]});
        }
        targetDevice = target.targetDeviceName
    }
}
