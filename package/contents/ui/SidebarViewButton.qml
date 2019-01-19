import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

SidebarItem {
	id: control

	property string appletIconName: ""
	readonly property string internalIconName: control.checked ? (appletIconName + "-selected") : appletIconName
	readonly property string appletIconFilename: appletIconName ? plasmoid.file("", "icons/" + internalIconName + ".svg") : ""

	checkedEdge: Qt.LeftEdge
	checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal

	PlasmaCore.SvgItem {
		id: icon

		svg: PlasmaCore.Svg {
			imagePath: control.appletIconFilename
		}

		// From FlatButton.qml
		width: config.flatButtonIconSize
		height: config.flatButtonIconSize
		anchors.centerIn: parent
		
		scale: control.zoomOnPush && control.pressed ? (control.height-5) / control.height : 1
		Behavior on scale { NumberAnimation { duration: 200 } }
	}
}
