import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

SidebarItem {
	id: control

	implicitWidth: config.flatButtonSize

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

		// From FlatButton.qml, modifed so icon is also 16px
		property int iconSize: units.roundToIconSize(config.flatButtonIconSize)
		width: iconSize
		height: iconSize
		anchors.centerIn: parent
		
		// From FlatButton.qml
		scale: control.zoomOnPush && control.pressed ? (control.height-5) / control.height : 1
		Behavior on scale { NumberAnimation { duration: 200 } }
	}
}
