import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import piw.helper 1.0

ApplicationWindow {
    id: appMain
    visible: true
    maximumWidth: 300
    maximumHeight: 400
    width: 300
    height: 400
    flags: Qt.FramelessWindowHint | Qt.Window
    title: qsTr("Pardus Image Writer")

    property bool requestForBurn : false
    property bool requestForQuit : false
    property bool requestForCancel : false

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

        onScheduleStarted: {
            target.scheduleStarted()
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

        onBurningCancelled: {
            isBurning = false
            burn.burningProcessCancelled()
        }
        onWarnUser: {
            burn.warnUserCalled()
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
        anchors {
            bottom: swipeView.bottom
            bottomMargin: 3
            horizontalCenter: parent.horizontalCenter
        }
        onCurrentIndexChanged: {
            swipeView.currentIndex = indicator.currentIndex
        }

    }

    Button {
        id: nextBtn
        Material.background: "#2c2c2c"
        width: parent.width / 6
        height: width * 3 / 4
        visible: swipeView.currentIndex == 2 ? false : true
        anchors {
            bottom: parent.bottom
            bottomMargin: -5
            right: parent.right
            rightMargin: 1
        }
        text: qsTr("NEXT")
        font.pointSize: height / 5 > 0 ? height / 5 : 9
        onClicked: {
            swipeView.currentIndex = swipeView.currentIndex + 1
        }
        hoverEnabled: true
        ToolTip.text: qsTr("Click to move forward")
        ToolTip.delay: 1000
        ToolTip.visible: hovered
        ToolTip.timeout: 3000
    }

    Button {
        id: backBtn
        Material.background: "#2c2c2c"
        width: parent.width / 6
        height: width * 3 / 4
        enabled: ! isBurning
        visible: swipeView.currentIndex == 0 ? false : true
        anchors {
            bottom: parent.bottom
            bottomMargin: -5
            left: parent.left
            rightMargin: 1
        }
        text: qsTr("BACK")
        font.pointSize: height / 5 > 0 ? height / 5 : 9
        onClicked: {
            swipeView.currentIndex = swipeView.currentIndex - 1
        }
        hoverEnabled: true
        ToolTip.text: qsTr("Click to move backward")
        ToolTip.delay: 1000
        ToolTip.visible: hovered
        ToolTip.timeout: 3000
    }

    Button {
        id: closeBtn
        Material.background: "#2c2c2c"
        width: parent.width / 12
        height: width + 12
        enabled: ! isBurning
        visible: true
        anchors {
            top: parent.top
            topMargin: -5
            right: parent.right
            rightMargin: 1
        }

        Image {
            anchors.centerIn: parent
            source: "../images/close.svg"
            sourceSize{
                height: parent.height - 8
                width: parent.width - 8
            }
            smooth: true
        }
        onClicked: {
            requestForQuit = true
            dialog.topic = qsTr("Are you sure to exit ?")
            dialog.open()
        }
        hoverEnabled: true
        ToolTip.text: qsTr("Click to close the application")
        ToolTip.delay: 1000
        ToolTip.visible: hovered
        ToolTip.timeout: 3000
    }

    Button {
        id: minimizeBtn
        Material.background: "#2c2c2c"
        width: parent.width / 12
        height: width + 12
        enabled: true
        visible: true
        anchors {
            top: parent.top
            topMargin: -5
            right: closeBtn.left
            rightMargin: 1
        }
        Image {
            anchors.centerIn: parent
            source: "../images/minimize.svg"
            sourceSize{
                height: parent.height - 8
                width: parent.width - 8
            }
            smooth: true
        }
        onClicked: {
            appMain.showMinimized()
        }
        hoverEnabled: true
        ToolTip.text: qsTr("Click to minimize")
        ToolTip.delay: 1000
        ToolTip.visible: hovered
        ToolTip.timeout: 3000
    }

    Button {
        id: aboutBtn
        Material.background: "#2c2c2c"
        enabled: true
        visible: true
        width: parent.width / 12
        height: width + 12
        hoverEnabled: true
        anchors {
            top: parent.top
            topMargin: -5
            left: parent.left
            leftMargin: 1
        }
        Image {
            anchors.centerIn: parent
            source: "../images/info.svg"
            sourceSize{
                height: parent.height - 6
                width: parent.width - 6
            }
            smooth: true
        }

        ToolTip.text: qsTr("About")
        ToolTip.delay: 1000
        ToolTip.visible: hovered
        ToolTip.timeout: 3000
        onClicked: {
            aboutDialog.open()
        }
    }

    Popup {
        id:aboutDialog
        width: appMain.width
        height: appMain.height * 9 / 10
        modal: true
        closePolicy: Popup.CloseOnPressOutside
        y: appMain.height / 10

        ColumnLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            spacing: parent.height / 30

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                text: "<b>"+ qsTr("Pardus Image Writer") + "</b>"
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap: true
                source: "../images/pardus.svg"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.horizontalAlignment
                text: qsTr("Author") + " : " + "Yunusemre Şentürk"
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Source Code") + " : " +"<a href='https://github.com/yunusem/pardus-imagewriter'>GitHub</a>"
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                text: qsTr("License") + " : " +"<a href='http://ozgurlisanslar.org.tr/gpl/gpl-v3/'>GPL v3</a>"
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.horizontalAlignment
                text: qsTr("Release") + " : " + "0.1.9"
            }

        }
        Button {
            id: okBtn
            highlighted: true
            Material.accent: "#2c2c2c"
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            visible: true
            enabled: true
            text: qsTr("Ok")
            onClicked: {
                aboutDialog.close()
            }
        }


    }

    Rectangle {
        id: dock
        color: "transparent"
        height: appMain.height / 10
        anchors {
            top: parent.top
            left: aboutBtn.right
            right: minimizeBtn.left
        }
        MouseArea {
            anchors.fill: parent
            property int cposx: 1
            property int cposy: 1
            onPressed: {
                cursorShape = Qt.SizeAllCursor
                var cpos = Qt.point(mouse.x,mouse.y);
                cposx = cpos.x
                cposy = cpos.y

            }
            onPositionChanged: {
                cursorShape = Qt.SizeAllCursor
                var delta = Qt.point(mouse.x - cposx, mouse.y - cposy);
                appMain.x += delta.x;
                appMain.y += delta.y;

            }
            onReleased: {
                cursorShape = Qt.ArrowCursor
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
                highlighted: true
                Material.accent: "#2c2c2c"
                visible: dialog.showButtons
                text: qsTr("Yes")
                onClicked: {
                    dialog.accepted()
                }
            }

            Button {
                id: noBtn
                highlighted: true
                Material.accent: "#2c2c2c"
                visible: dialog.showButtons
                text: qsTr("No")
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
                console.log(dialog.topic)
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
        if (requestForCancel) {
            helper.cancelWriting()
        }

    }
    onDialogRejected: {
        requestForQuit = false
        requestForBurn = false
        requestForCancel = false
    }

    Component.onCompleted: {
        for (var i = 0; i < helper.devices.length; i++) {
            cbItems.append({"text": helper.devices[i].split(" - ")[1]});
        }
        targetDevice = target.targetDeviceName
    }
    onClosing: {
        close.accepted = false
        raise()
        showNormal()
        if (isBurning) {
            dialog.topic = qsTr("Writing process is ongoing.\nTerminating it is not recommended.\n\nAre you sure to exit ?")
        } else {
            dialog.topic = qsTr("Are you sure to exit ?")
        }
        requestForQuit = true
        dialog.open()
    }
}
