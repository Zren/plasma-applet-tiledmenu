import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Rectangle {
	id: tileItemView
	color: appObj.backgroundColor
	property color gradientBottomColor: Qt.darker(appObj.backgroundColor, 2.0)

	Component {
		id: tileGradient
		Gradient {
			GradientStop { position: 0.0; color: appObj.backgroundColor }
			GradientStop { position: 1.0; color: tileItemView.gradientBottomColor }
		}
	}
	gradient: appObj.backgroundGradient ? tileGradient.createObject(tileItemView) : null

	readonly property int smallIconSize: 32 * PlasmaCore.Units.devicePixelRatio
	readonly property int mediumIconSize: 72 * PlasmaCore.Units.devicePixelRatio
	readonly property int largeIconSize: 96 * PlasmaCore.Units.devicePixelRatio
	readonly property int tilePadding: 8 * PlasmaCore.Units.devicePixelRatio

	readonly property int labelAlignment: appObj.isGroup ? config.groupLabelAlignment : config.tileLabelAlignment

	property bool hovered: false

	states: [
		State {
			when: modelData.w == 1 && modelData.h >= 1
			PropertyChanges { target: icon; size: smallIconSize }
			PropertyChanges { target: label; visible: false }
		},
		State {
			when: modelData.w >= 2 && modelData.h == 1
			AnchorChanges { target: icon
				anchors.horizontalCenter: undefined
				anchors.left: tileItemView.left
			}
			PropertyChanges { target: icon; anchors.leftMargin: tilePadding }
			PropertyChanges { target: label
				verticalAlignment: Text.AlignVCenter
			}
			AnchorChanges { target: label
				anchors.left: icon.right
			}
		},
		State {
			when: (modelData.w >= 2 && modelData.h == 2) || (modelData.w == 2 && modelData.h >= 2)
			PropertyChanges { target: icon; size: mediumIconSize }
		},
		State {
			when: modelData.w >= 3 && modelData.h >= 3
			PropertyChanges { target: icon; size: largeIconSize }
		}
	]

	Image {
		id: backgroundImage
		anchors.fill: parent
		visible: appObj.backgroundImage
		source: appObj.backgroundImage
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
	}

	PlasmaCore.IconItem {
		id: icon
		visible: appObj.showIcon
		source: appObj.iconSource
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		// property int size: 72 // Just a default, overriden in State change
		property int size: Math.min(parent.width, parent.height) / 2
		width: appObj.showIcon ? size : 0
		height: appObj.showIcon ? size : 0
		anchors.fill: appObj.iconFill ? parent : null
		smooth: appObj.iconFill
	}

	PlasmaComponents3.Label {
		id: label
		visible: appObj.showLabel
		text: appObj.labelText
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.leftMargin: tilePadding
		anchors.rightMargin: tilePadding
		anchors.bottomMargin: tilePadding/2
		anchors.left: parent.left
		anchors.right: parent.right
		wrapMode: Text.Wrap
		horizontalAlignment: labelAlignment
		verticalAlignment: Text.AlignBottom
		width: parent.width
		// Already handled https://api.kde.org/frameworks/plasma-framework/html/qml_2Label_8qml_source.html renderType: Text.QtRendering // Fix pixelation when scaling. Plasma.Label uses NativeRendering.
		// style: Text.Outline
		// styleColor: appObj.backgroundGradient ? tileItemView.gradientBottomColor : appObj.backgroundColor
	}
}
