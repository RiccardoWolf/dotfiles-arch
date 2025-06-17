import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: overlay
    anchors.fill: parent
    visible: false
    z: 99

    Rectangle {
        anchors.fill: parent
        color: config.base
    }

    Rectangle {
        id: barBg
        width: parent.width * 0.3
        height: 8
        radius: 4
        color: config.overlay1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: bar
        height: barBg.height
        width: 0
        radius: barBg.radius
        color: config.sapphire
        anchors.left: barBg.left
        anchors.verticalCenter: barBg.verticalCenter

        SequentialAnimation on width {
            running: overlay.visible
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: barBg.width; duration: 1500 }
            NumberAnimation { from: barBg.width; to: 0; duration: 1500 }
        }
    }
}
