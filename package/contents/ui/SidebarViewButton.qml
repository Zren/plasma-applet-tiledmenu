import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

SidebarItem {
	id: control

	implicitWidth: config.flatButtonSize

	property string appletIconName: ""
	readonly property string appletIconFilename: appletIconName ? Qt.resolvedUrl("../icons/" + appletIconName + ".svg") : ""

	checkedEdge: Qt.LeftEdge
	checkedEdgeWidth: 4 * Screen.devicePixelRatio // Twice as thick as normal

	Kirigami.Icon {
		id: icon
		source: control.appletIconFilename

		isMask: true // Force color
		color: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor

		// From FlatButton.qml, modifed so icon is also 16px
		property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(config.flatButtonIconSize)
		width: iconSize
		height: iconSize
		anchors.centerIn: parent

		// Note: Disabled this seems it seems to create a blurry icon after release.
		// From FlatButton.qml
		// scale: control.zoomOnPush && control.pressed ? (control.height-5) / control.height : 1
		// Behavior on scale { NumberAnimation { duration: 200 } }
	}
}
