import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

JumpToSectionView {
	id: jumpToLetterView

	squareView: appsModel.order == "alphabetical"

	onUpdate: {
		// console.log('jumpToLetterView.update()')
		var sections = []
		for (var i = 0; i < appsModel.allAppsModel.count; i++) {
			var app = appsModel.allAppsModel.get(i)
			var section = app.sectionKey
			if (sections.indexOf(section) == -1) {
				sections.push(section)
			}
		}
		availableSections = sections
		// console.log('jumpToLetterView.update.availableSections', sections)

		if (appsModel.order == "alphabetical") {
			sections = presetSections.slice() // shallow copy
			for (var i = 0; i < availableSections.length; i++) {
				var section = availableSections[i]
				if (sections.indexOf(section) == -1) {
					sections.push(section)
				}
			}
			allSections = sections
		} else {
			allSections = availableSections
		}
		// console.log('jumpToLetterView.update.allSections', allSections)
	}

	presetSections: [
		appsModel.recentAppsSectionKey,
		'&',
		'0-9',
		'A', 'B', 'C', 'D', 'E', 'F',
		'G', 'H', 'I', 'J', 'K', 'L',
		'M', 'N', 'O', 'P', 'Q', 'R',
		'S', 'T', 'U', 'V', 'W', 'X',
		'Y', 'Z',
	]

	// delegate: PlasmaComponents.ToolButton {
	// 	width: jumpToLetterView.cellWidth
	// 	height: jumpToLetterView.cellHeight

	// 	readonly property string section: modelData || ''
	// 	readonly property bool isRecentApps: section == i18n("Recent Apps")

	// 	enabled: availableSections.indexOf(section) >= 0

	// 	font.pixelSize: height * 0.6

	// 	iconName: {
	// 		if (jumpToLetterView.squareView) {
	// 			if (isRecentApps) {
	// 				return 'view-history'
	// 			} else {
	// 				return ''
	// 			}
	// 		} else {
	// 			return 'view-list-tree'
	// 		}
	// 	}
	// 	text: {
	// 		if (isRecentApps) {
	// 			return  '' // Use '◷' icon
	// 		} else if (section == '0-9') {
	// 			return '#'
	// 		} else {
	// 			return section
	// 		}
	// 	}
		
	// 	onClicked: {
	// 		appsView.show()
	// 		appsView.jumpToSection(section)
	// 	}
	// }
}
