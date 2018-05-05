import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtGraphicalEffects 1.0

Item {
	id: style

	property int paddingTop: surfaceNormal.margins.top
	property int paddingLeft: surfaceNormal.margins.left
	property int paddingRight: surfaceNormal.margins.right
	property int paddingBottom: surfaceNormal.margins.bottom

	ButtonShadow {
		id: shadow
		visible: control.activeFocus
		anchors.fill: parent
		enabledBorders: surfaceNormal.enabledBorders
		state: {
			if (control.pressed) {
				return "hidden"
			} else if (control.containsMouse) {
				return "hover"
			} else if (control.activeFocus) {
				return "focus"
			} else {
				return "shadow"
			}
		}
	}
	PlasmaCore.FrameSvgItem {
		id: surfaceNormal
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "normal"
		enabledBorders: "AllBorders"
	}
	PlasmaCore.FrameSvgItem {
		id: surfacePressed
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "pressed"
		enabledBorders: surfaceNormal.enabledBorders
		opacity: 0
	}

	state: (control.pressed || control.checked ? "pressed" : (control.containsMouse ? "hover" : "normal"))

	states: [
		State { name: "normal"
			PropertyChanges {
				target: surfaceNormal
				opacity: 0
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 0
			}
		},
		State { name: "hover"
			PropertyChanges {
				target: surfaceNormal
				opacity: 1
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 0
			}
		},
		State { name: "pressed"
			PropertyChanges {
				target: surfaceNormal
				opacity: 0
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 1
			}
		}
	]

	transitions: [
		Transition {
			//Cross fade from pressed to normal
			ParallelAnimation {
				NumberAnimation { target: surfaceNormal; property: "opacity"; duration: 100 }
				NumberAnimation { target: surfacePressed; property: "opacity"; duration: 100 }
			}
		}
	]

}
