import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

SidebarItem {
	id: control

	implicitWidth: config.flatButtonSize

	property string appletIconName: ""
	readonly property string internalIconName: control.checked ? (appletIconName + "-selected") : appletIconName
	readonly property string appletIconFilename: appletIconName ? Qt.resolvedUrl("../icons/" + internalIconName + ".svg") : ""

	checkedEdge: Qt.LeftEdge
	checkedEdgeWidth: 4 * Screen.devicePixelRatio // Twice as thick as normal

	KSvg.SvgItem {
		id: icon

		svg: KSvg.Svg {
			imagePath: control.appletIconFilename
		}

		// From FlatButton.qml, modifed so icon is also 16px
		property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(config.flatButtonIconSize)
		width: iconSize
		height: iconSize
		anchors.centerIn: parent
		
		// From FlatButton.qml
		scale: control.zoomOnPush && control.pressed ? (control.height-5) / control.height : 1
		Behavior on scale { NumberAnimation { duration: 200 } }
	}
}
