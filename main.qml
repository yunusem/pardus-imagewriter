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
    //flags: Qt.FramelessWindowHint
    title: qsTr("Pardus Image Writer")

    property bool isInteractive : false
    property bool isBurning : false
    property string filePath : ""
    property string fileName : ""
    property string targetDevice: ""

    Helper {
        id: helper
        onTerminateCalled: {
            console.log("Terminate Called")
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
            File{
                id: file

            }
        }
        Page {
            Target{
                id: target
            }
        }

        Page {
            Burn {
                id: burn
            }
        }
    }

    PageIndicator {
        id: indicator

        count: swipeView.count
        currentIndex: swipeView.currentIndex

        anchors.bottom: swipeView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Component.onCompleted: {
        for (var i = 0; i < helper.devices.length; i++) {
            cbItems.append({"text": helper.devices[i].split(" - ")[1]});
        }
        targetDevice = target.targetDeviceName        
    }
}
