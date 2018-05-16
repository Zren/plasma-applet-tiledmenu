import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.kquickcontrolsaddons 2.0 // KCMShell

import "Utils.js" as Utils

Item {
	id: searchView
	width: config.showAppList ? config.leftSectionWidth : config.sidebarWidth
	height: config.popupHeight
	property alias searchResultsView: searchResultsView
	property alias appsView: appsView
	property alias hideAppListView: hideAppListView
	property alias tileEditorView: tileEditorViewLoader.item
	property alias tileEditorViewLoader: tileEditorViewLoader
	property alias searchField: searchField

	property bool searchOnTop: false

	states: [
		State {
			name: "searchOnTop"
			when: searchOnTop
			PropertyChanges {
				target: stackViewContainer
				anchors.topMargin: searchField.height
			}
			PropertyChanges {
				target: searchField
				anchors.top: searchField.parent.top
			}
		},
		State {
			name: "searchOnBottom"
			when: !searchOnTop
			PropertyChanges {
				target: stackViewContainer
				anchors.bottomMargin: searchField.height
			}
			PropertyChanges {
				target: searchField
				anchors.bottom: searchField.parent.bottom
			}
		}
	]

	SidebarView {
		id: sidebarView
	}


	Item {
		id: stackViewContainer
		width: config.appListWidth
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom

		Item {
			id: hideAppListView

			function show() {
				if (stackView.currentItem != hideAppListView) {
					stackView.delegate = stackView.noTransition
					stackView.push({
						item: hideAppListView,
						replace: true,
					})
				}
			}
		}

		SearchResultsView {
			id: searchResultsView
			visible: false

			Connections {
				target: search
				onQueryChanged: {
					if (search.query.length > 0 && stackView.currentItem != searchResultsView) {
						stackView.push(searchResultsView, true)
					}
					searchResultsView.filterViewOpen = false
				}
			}

			onVisibleChanged: {
				if (!visible) { // !stackView.currentItem
					search.query = ""
				}
			}

			function showDefaultSearch() {
				if (stackView.currentItem != searchResultsView) {
					stackView.push(searchResultsView, true)
				}
				search.applyDefaultFilters()
			}
		}
		
		AppsView {
			id: appsView
			visible: false

			function showAppsAlphabetically() {
				appsModel.order = "alphabetical"
				show()
			}

			function showAppsCategorically() {
				appsModel.order = "categories"
				show()
			}

			function show() {
				if (stackView.currentItem != appsView) {
					stackView.delegate = stackView.panUp
					stackView.push({
						item: appsView,
						replace: true,
					})
				}
				appsView.scrollToTop()
			}
		}

		// TM3.Main {
		// 	id: appsView
		// 	// width: parent.width
		// 	// height: parent.height

		// 	function show() {
		// 		if (stackView.currentItem != appsView) {
		// 			stackView.push(appsView, true)
		// 		}
		// 		appsView.scrollToTop()
		// 	}
		// }

		// Item {
		// 	id: appsView
		// }

		Loader {
			id: tileEditorViewLoader
			source: "TileEditorView.qml"
			visible: false
			active: false
			// asynchronous: true
			function open(tile) {
				active = true
				item.open(tile)
			}
		}

		SearchStackView {
			id: stackView
			anchors.fill: parent
			initialItem: hideAppListView // appsView


			onCurrentItemChanged: {
				if (currentItem == hideAppListView) {
					config.showAppList = false
				} else {
					config.showAppList = true
				}
			}
		}
	}


	SearchField {
		id: searchField
		// width: 430
		height: config.searchFieldHeight
		anchors.leftMargin: config.sidebarWidth
		anchors.left: parent.left
		anchors.right: parent.right

		listView: stackView.currentItem && stackView.currentItem.listView ? stackView.currentItem.listView : []
	}
}
