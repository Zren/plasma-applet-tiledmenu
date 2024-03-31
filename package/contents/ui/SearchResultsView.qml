import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

GridLayout {
	id: searchResultsView
	rowSpacing: 0
	property alias listView: searchResultsList
	property bool filterViewOpen: false
	
	RowLayout {
		id: searchFiltersRow
		Layout.row: searchView.searchOnTop ? 2 : 0
		Layout.preferredHeight: config.searchFilterRowHeight - 1 // -1px is for the underline seperator
		Layout.fillWidth: true

		FlatButton {
			icon.name: "system-search-symbolic"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.applyDefaultFilters()
			checked: search.isDefaultFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		FlatButton {
			icon.name: "window"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.filters = ['services']
			checked: search.isAppsFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		FlatButton {
			icon.name: "document-new"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.filters = ['baloosearch']
			checked: search.isFileFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		// FlatButton {
		// 	icon.name: "globe"
		// 	Layout.preferredHeight: parent.Layout.preferredHeight
		// 	Layout.preferredWidth: parent.Layout.preferredHeight
		// 	onClicked: search.filters = ['bookmarks']
		// 	checked: search.isBookmarksFilter
		// 	checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		// }

		Item { Layout.fillWidth: true }

		FlatButton {
			id: moreFiltersButton
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: moreFiltersButtonRow.implicitWidth + padding*2
			// property int padding: (config.searchFilterRowHeight - config.flatButtonIconSize) / 2
			padding: (config.searchFilterRowHeight - config.flatButtonIconSize) / 2
			// enabled: false

			RowLayout {
				id: moreFiltersButtonRow
				anchors.centerIn: parent
				anchors.margins: parent.padding
				
				PlasmaComponents3.Label {
					id: moreFiltersButtonLabel
					text: i18n("Filters")
				}
				Kirigami.Icon {
					source: "usermenu-down"
					rotation: searchResultsView.filterViewOpen ? 180 : 0
					Layout.preferredHeight: config.flatButtonIconSize
					Layout.preferredWidth: config.flatButtonIconSize

					Behavior on rotation {
						NumberAnimation { duration: Kirigami.Units.longDuration }
					}
				}
			}

			onClicked: searchResultsView.filterViewOpen = !searchResultsView.filterViewOpen
		}
	}

	Rectangle {
		color: "#111"
		height: 1
		width: parent.width
		// anchors.bottom: searchFiltersRow.bottom - 1
	}

	QQC2.StackView {
		id: searchResultsViewStackView
		Layout.row: searchView.searchOnTop ? 0 : 2
		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true
		initialItem: searchResultsListScrollView

		Connections {
			target: searchResultsView
			function onFilterViewOpenChanged() {
				if (searchResultsView.filterViewOpen) {
					searchResultsViewStackView.push(searchFiltersViewScrollView)
				} else {
					searchResultsViewStackView.pop()
				}
			}
		}

		QQC2.ScrollView {
			id: searchResultsListScrollView
			visible: false

			SearchResultsList {
				id: searchResultsList
			}
		}

		QQC2.ScrollView {
			id: searchFiltersViewScrollView
			visible: false

			SearchFiltersView {
				id: searchFiltersView
			}
		}
		
	}
}
