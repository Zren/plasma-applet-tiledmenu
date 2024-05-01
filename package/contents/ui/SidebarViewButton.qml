import QtQuick
import QtQuick.Shapes
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

SidebarItem {
	id: control

	implicitWidth: config.flatButtonSize

	property string appletIconName: ""
	readonly property string internalIconName: appletIconName // control.checked ? (appletIconName + "-selected") : appletIconName
	readonly property string appletIconFilename: appletIconName ? Qt.resolvedUrl("../icons/" + internalIconName + ".svg") : ""

	checkedEdge: Qt.LeftEdge
	checkedEdgeWidth: 4 * Screen.devicePixelRatio // Twice as thick as normal

	// From FlatButton.qml, modifed so icon is also 16px
	property int iconSize: Kirigami.Units.iconSizes.roundedIconSize(config.flatButtonIconSize)

	default property alias shapePathChildren: shapePath.pathElements
	property int viewBoxSize: 16
	readonly property real viewBoxScale: control.iconSize / control.viewBoxSize

	// Item {
	Shape {
		visible: false
		ShapePath {
			id: shapePath
			scale: Qt.size(control.viewBoxScale, control.viewBoxScale)
			fillColor: control.checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
			fillRule: ShapePath.WindingFill
			strokeWidth: -1
		}
		preferredRendererType: Shape.CurveRenderer // Aliasing

		width: control.iconSize
		height: control.iconSize
		anchors.centerIn: parent

		// From FlatButton.qml
		scale: control.zoomOnPush && control.pressed ? (control.height-5) / control.height : 1
		Behavior on scale { NumberAnimation { duration: 200 } }
	}

	KSvg.SvgItem {
		id: icon

		Kirigami.Theme.inherit: true

		svg: KSvg.Svg {
			imagePath: control.appletIconFilename
			// colorSet: control.checked ? KSvg.Svg.Selection : KSvg.Svg.Button
			// colorSet: KSvg.Svg.Button
			// colorSet: KSvg.Svg.Window
			// colorSet: KSvg.Svg.Complementary
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
