import QtQuick 2.0

Item {
	property int dropShadowSize: 4 * units.devicePixelRatio
	property int roundShadowHack: dropShadowSize/2 // "dropShadowSize/2" draws enough to fool the eye.
	Rectangle {
		id: topShadow
		anchors.left: parent.left
		anchors.bottom: parent.top
		width: parent.width + roundShadowHack
		height: dropShadowSize
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#00000000" }
			GradientStop { position: 1.0; color: "#60000000" }
		}
	}
	Rectangle {
		id: rightShadow
		anchors.bottom: parent.top
		anchors.left: parent.right
		height: dropShadowSize
		width: parent.height

		transformOrigin: Item.BottomLeft
		rotation: 90

		gradient: Gradient {
			GradientStop { position: 0.0; color: "#00000000" }
			GradientStop { position: 1.0; color: "#60000000" }
		}
	}
	Rectangle {
		id: bottomShadow
		anchors.left: parent.left
		anchors.top: parent.bottom
		width: parent.width + roundShadowHack
		height: dropShadowSize
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#90000000" }
			GradientStop { position: 1.0; color: "#00000000" }
		}
	}
	Rectangle {
		id: leftShadow
		anchors.bottom: parent.top
		anchors.left: parent.left
		height: dropShadowSize
		width: parent.height

		transformOrigin: Item.BottomLeft
		rotation: 90

		gradient: Gradient {
			GradientStop { position: 0.0; color: "#00000000" }
			GradientStop { position: 1.0; color: "#20000000" }
		}
	}
}
