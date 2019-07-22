import QtQuick 2.0

HoverOutlineEffect {
	id: hoverOutlineButtonEffect
	anchors.fill: parent
	hoverRadius: Math.max(width/2, height)
	pressedRadius: width
	mouseArea: __control
}
