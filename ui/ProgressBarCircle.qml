import QtQuick 2.0
import QtQml 2.2

Item {
    id: progressbarcircle

    width: 200
    height: 200

    property real value : 0
    property real maximumValue : 360
    property real arcEnd: value * 360 / maximumValue
    property real thickness: 20
    property string colorCircle: "#ffcb08"
    property string colorBackground: "#2c2c2c"
    property alias endAnimation: animationArcEnd.enabled
    property int animationDuration: 10

    onArcEndChanged: canvas.requestPaint()

    Behavior on arcEnd {
        id: animationArcEnd
        enabled: true
        NumberAnimation {
            duration: progressbarcircle.animationDuration
            easing.type: Easing.OutExpo
        }
    }

    Text {
        anchors.centerIn: parent
        text: value >= maximumValue ? maximumValue.toFixed(0) + " MB" : value.toFixed(0) + " MB"
        color: colorCircle
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: -270

        onPaint: {
            var ctx = getContext("2d")
            var x = width / 2
            var y = height / 2
            var start = 0
            var end = Math.PI * (parent.arcEnd / 180)
            ctx.reset()
            ctx.beginPath();
            ctx.arc(x, y, (width / 2) - parent.thickness / 2, 0, Math.PI * 2, false)
            ctx.lineWidth = parent.thickness
            ctx.strokeStyle = parent.colorBackground
            ctx.stroke()
            ctx.beginPath();
            ctx.arc(x, y, (width / 2) - parent.thickness / 2, start, end, false)
            ctx.lineWidth = parent.thickness
            ctx.strokeStyle = parent.colorCircle
            ctx.stroke()

        }
    }
}
