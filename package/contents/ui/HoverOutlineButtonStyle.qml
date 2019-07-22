import QtQuick 2.0

Item {
	id: style
	property int paddingTop: 0
	property int paddingRight: 0
	property int paddingBottom: 0
	property int paddingLeft: 0

	Loader {
		id: hoverOutlineEffectLoader
		anchors.fill: parent
		active: control.containsMouse
		visible: active
		source: "HoverOutlineButtonEffect.qml"

		property var __control: control
	}

}
