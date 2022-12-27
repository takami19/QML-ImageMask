import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.12

Item {
    id: root
    property string imgsrc: ""
    property string placeholder: ""
    property int cornerRadius: 24
    property int borderWidth: 0
    property color borderColor: "white"
    property string maskSvgPath: ""
    property bool maskScaleToFit: true
    property int maskWidth: 0
    property int maskHeight: 0

    Shape {
        id: maskShape
        anchors.fill: parent
        visible: false
        ShapePath {
            scale: getScale()
            fillColor: "gray"
            strokeWidth: 0
            strokeColor: "transparent"
            PathSvg {
                path: maskSvgPath ? maskSvgPath : priv.getRoundRectPath(
                                        root.width, root.height,
                                        root.cornerRadius)
            }
        }
    }

    Image {
        id: image
        visible: !priv.needMask
        anchors.fill: parent
        anchors.centerIn: parent
        source: root.imgsrc
        fillMode: Image.PreserveAspectCrop
    }

    OpacityMask {
        anchors.fill: image
        source: image
        visible: priv.needMask
        enabled: priv.needMask
        maskSource: maskShape
    }

    Shape {
        anchors.fill: parent
        visible: borderWidth > 0
        ShapePath {
            scale: getScale()
            strokeWidth: root.borderWidth
            strokeColor: root.borderColor
            fillColor: "transparent"
            PathSvg {
                path: maskSvgPath ? maskSvgPath : priv.getRoundRectPath(
                                        root.width, root.height,
                                        root.cornerRadius)
            }
        }
    }

    function getScale() {
        let scale = Qt.size(1, 1)
        if (maskScaleToFit && maskSvgPath && maskShape.width > 0
                && maskShape.height > 0) {
            const mWidth = maskWidth > 0 ? maskWidth : maskShape.width
            const mHeight = maskHeight > 0 ? maskHeight : maskShape.height
            scale = Qt.size(maskShape.width / mWidth,
                            maskShape.height / mHeight)
        }

        return scale
    }

    QtObject {
        id: priv
        property string roundRectPathTemplate: "M%R,0 h%W a%R,%R 0 0 1 %R,%R v%H a%R,%R 0 0 1 -%R,%R h-%W a%R,%R 0 0 1 -%R,-%R v-%H a%R,%R 0 0 1 %R,-%R z"
        property bool needMask: cornerRadius > 0 || maskSvgPath

        function replaceAll(string, search, replace) {
            return string.split(search).join(replace)
        }
        function getRoundRectPath(width, height, radius) {
            let path = roundRectPathTemplate
            path = replaceAll(path, "%R", radius)
            path = replaceAll(path, "%W", width - radius * 2)
            path = replaceAll(path, "%H", height - radius * 2)
            return path
        }
    }
}
