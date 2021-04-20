import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

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
			return 70 * PlasmaCore.Units.devicePixelRatio
		} else {
			return 36 * PlasmaCore.Units.devicePixelRatio
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

	delegate: AppToolButton {
		width: jumpToLetterView.cellWidth
		height: jumpToLetterView.cellHeight

		readonly property string section: modelData || ''
		readonly property bool isRecentApps: section == appsModel.recentAppsSectionKey
		readonly property var sectionIcon: appsModel.allAppsModel.sectionIcons[section] || null

		enabled: availableSections.indexOf(section) >= 0

		font.pixelSize: height * 0.6

		iconSource: {
			if (isRecentApps) {
				return 'view-history'
			} else if (jumpToLetterView.squareView) {
				return ''
			} else {
				return sectionIcon
			}
		}
		text: {
			if (isRecentApps) {
				if (jumpToLetterView.squareView) {
					return  '' // Use '◷' icon
				} else {
					return appsModel.recentAppsSectionLabel
				}
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
