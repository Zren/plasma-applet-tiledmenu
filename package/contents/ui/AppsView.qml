import QtQuick 2.0
import QtQuick.Controls 2.3 as QQC2 // Qt 5.10
import org.kde.plasma.core 2.0 as PlasmaCore

QQC2.ScrollView {
	id: appsView
	property alias listView: appsListView

	// The horizontal ScrollBar always appears in QQC2 for some reason.
	// The PC3 is drawn as if it thinks the scrollWidth is 0, which is
	// possible since it inits at width=350px, then changes to 0px until
	// the popup is opened before it returns to 350px.
	QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

	KickerListView {
		id: appsListView

		section.property: 'sectionKey'
		// section.criteria: ViewSection.FirstCharacter

		model: appsModel.allAppsModel // Should be populated by the time this is created

		section.delegate: KickerSectionHeader {
			enableJumpToSection: true
		}

		delegate: MenuListItem {
			secondRowVisible: config.appDescriptionBelow
			description: config.appDescriptionVisible ? modelDescription : ''
		}

		iconSize: config.menuItemHeight
		showItemUrl: false
	}

	function scrollToTop() {
		appsListView.positionViewAtBeginning()
	}

	function jumpToSection(section) {
		for (var i = 0; i < appsListView.model.count; i++) {
			var app = appsListView.model.get(i)
			if (section == app.sectionKey) {
				appsListView.currentIndex = i
				appsListView.positionViewAtIndex(i, ListView.Beginning)
				break
			}
		}
	}
}
