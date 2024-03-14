import QtQuick

HoverOutlineEffect {
	id: hoverOutlineButtonEffect
	anchors.fill: parent
	hoverRadius: Math.max(width/2, height)
	pressedRadius: width
	mouseArea: __mouseArea
}
