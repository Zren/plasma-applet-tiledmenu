import QtQuick 2.0
import QtGraphicalEffects 1.0


Item {
	id: hoverOutlineEffect
	property int hoverOutlineSize: 1 * units.devicePixelRatio
	property int hoverRadius: 40
	property int pressedRadius: hoverRadius
	property bool useOutlineMask: true

	property int effectRadius: control.pressed ? pressedRadius : hoverRadius
	Behavior on effectRadius {
		NumberAnimation {
			duration: units.longDuration
		}
	}
	
	visible: control.containsMouse

	Rectangle {
		id: hoverOutline
		visible: !hoverOutlineEffect.useOutlineMask
		anchors.fill: parent
		// color: "transparent"
		color: control.pressed ? "#44ffffff" : "#11ffffff"
		border.color: "#88ffffff"
		border.width: hoverOutlineSize

		Behavior on color {
			ColorAnimation {
				duration: units.longDuration
			}
		}
	}

	RadialGradient {
		id: hoverOutlineMask
		visible: false
		anchors.fill: parent
		horizontalOffset: hoverOutlineEffect.visible ? control.mouseX - width/2 : 0
		verticalOffset: hoverOutlineEffect.visible ? control.mouseY - height/2 : 0
		horizontalRadius: effectRadius
		verticalRadius: effectRadius
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#FFFFFFFF" }
			GradientStop { position: 1; color: "#00FFFFFF" }
		}
	}

	OpacityMask {
		anchors.fill: parent
		visible: hoverOutlineEffect.useOutlineMask
		source: hoverOutline
		maskSource: hoverOutlineMask
	}
}
