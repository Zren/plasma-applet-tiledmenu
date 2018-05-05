import QtQuick 2.0

Item {
	id: style
	property int paddingTop: 0
	property int paddingRight: 0
	property int paddingBottom: 0
	property int paddingLeft: 0

	HoverOutlineEffect {
		id: hoverOutlineEffect
		anchors.fill: parent
		hoverRadius: width/2
		pressedRadius: width
	}

}
