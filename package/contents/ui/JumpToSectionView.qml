import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

GridView {
	id: jumpToSectionView

	Layout.fillWidth: true
	Layout.fillHeight: true

	clip: true

	property bool squareView: false

	Connections {
		target: appsModel.allAppsModel
		onRefreshed: jumpToLetterView.update()
	}

	signal update()

	property var availableSections: []
	property var presetSections: []
	property var allSections: []
	model: allSections

	property int buttonSize: {
		if (squareView) {
			return 70 * units.devicePixelRatio
		} else {
			return 36 * units.devicePixelRatio
		}
	}

	cellWidth: {
		if (squareView) {
			return buttonSize
		} else {
			return width
		}
	}
	cellHeight: buttonSize

	delegate: PlasmaComponents.ToolButton {
		width: jumpToLetterView.cellWidth
		height: jumpToLetterView.cellHeight

		readonly property string section: modelData || ''
		readonly property bool isRecentApps: section == i18n("Recent Apps")

		enabled: availableSections.indexOf(section) >= 0

		font.pixelSize: height * 0.6

		iconName: {
			if (isRecentApps) {
				return 'view-history'
			} else if (jumpToLetterView.squareView) {
				return ''
			} else {
				return 'view-list-tree'
			}
		}
		text: {
			if (jumpToLetterView.squareView && isRecentApps) {
				return  '' // Use '◷' icon
			} else if (jumpToLetterView.squareView && section == '0-9') {
				return '#'
			} else {
				return section
			}
		}
		
		onClicked: {
			appsView.show(stackView.zoomIn)
			appsView.jumpToSection(section)
		}
	}
}
