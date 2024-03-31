import QtQuick
import org.kde.kirigami as Kirigami


// https://doc.qt.io/qt-5/graphicaleffects.html
// https://doc.qt.io/qt-6/qtgraphicaleffects5-index.html
// import QtGraphicalEffects 1.0 // TODO Deprecated in Qt6
import Qt5Compat.GraphicalEffects as QtGraphicalEffects

Item {
	id: hoverOutlineEffect
	property int hoverOutlineSize: 1 * Screen.devicePixelRatio
	property int hoverRadius: 40
	property int pressedRadius: hoverRadius
	property bool useOutlineMask: true

	property var mouseArea
	property bool hovered: mouseArea ? mouseArea.containsMouse : false
	property bool pressed: mouseArea ? mouseArea.pressed : false
	property int mouseX: mouseArea ? mouseArea.mouseX : width/2
	property int mouseY: mouseArea ? mouseArea.mouseY : height/2

	property int effectRadius: hoverOutlineEffect.pressed ? pressedRadius : hoverRadius
	Behavior on effectRadius {
		NumberAnimation {
			duration: Kirigami.Units.longDuration
		}
	}

	visible: hoverOutlineEffect.hovered

	function alpha(c, a) {
		return Qt.rgba(c.r, c.g, c.b, a)
	}
	property color effectColor: Kirigami.Theme.textColor
	property color fillColor: alpha(effectColor, 1/16)
	property color pressedFillColor: alpha(effectColor, 4/16)
	property color borderColor: alpha(effectColor, 8/16)

	Rectangle {
		id: hoverSolidFill
		anchors.fill: parent
		anchors.margins: hoverOutlineSize
		color: fillColor
	}

	Rectangle {
		id: hoverOutline
		visible: !hoverOutlineEffect.useOutlineMask
		anchors.fill: parent
		// color: "transparent"
		color: hoverOutlineEffect.pressed ? pressedFillColor : fillColor
		border.color: borderColor
		border.width: hoverOutlineSize

		Behavior on color {
			ColorAnimation {
				duration: Kirigami.Units.longDuration
			}
		}
	}

	QtGraphicalEffects.RadialGradient {
		id: hoverOutlineMask
		visible: false
		anchors.fill: parent
		horizontalOffset: hoverOutlineEffect.visible ? hoverOutlineEffect.mouseX - width/2 : 0
		verticalOffset: hoverOutlineEffect.visible ? hoverOutlineEffect.mouseY - height/2 : 0
		horizontalRadius: effectRadius
		verticalRadius: effectRadius
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#FFFFFFFF" }
			GradientStop { position: 1; color: "#00FFFFFF" }
		}
	}

	QtGraphicalEffects.OpacityMask {
		anchors.fill: parent
		visible: hoverOutlineEffect.useOutlineMask
		source: hoverOutline
		maskSource: hoverOutlineMask
	}
}
