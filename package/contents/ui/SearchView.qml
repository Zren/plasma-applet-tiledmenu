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
	implicitWidth: config.appAreaWidth
	// Behavior on implicitWidth {
	// 	NumberAnimation { duration: 400 }
	// }

	visible: opacity > 0
	opacity: config.showSearch ? 1 : 0
	// Behavior on opacity {
	// 	NumberAnimation { duration: 400 }
	// }

	Connections {
		target: search
		onIsSearchingChanged: {
			if (search.isSearching) {
				searchView.showSearchView()
			}
		}
	}
	clip: true

	// width: config.leftSectionWidth
	height: config.popupHeight
	property alias searchResultsView: searchResultsView
	property alias appsView: appsView
	property alias tileEditorView: tileEditorViewLoader.item
	property alias tileEditorViewLoader: tileEditorViewLoader
	property alias searchField: searchField
	property alias jumpToLetterView: jumpToLetterView

	readonly property bool showingOnlyTiles: !config.showSearch
	readonly property bool showingAppList: stackView.currentItem == appsView || stackView.currentItem == jumpToLetterView
	readonly property bool showingAppsAlphabetically: config.showSearch && appsModel.order == "alphabetical" && showingAppList
	readonly property bool showingAppsCategorically: config.showSearch && appsModel.order == "categories" && showingAppList
	readonly property bool showSearchField: config.hideSearchField ? !!searchField.text : true

	property bool searchOnTop: false

	function showDefaultView() {
		var defView = plasmoid.configuration.defaultAppListView
		if (defView == 'Alphabetical') {
			appsView.showAppsAlphabetically()
		} else if (defView == 'Categories') {
			appsView.showAppsCategorically()
		} else if (defView == 'JumpToLetter') {
			jumpToLetterView.showLetters()
		} else if (defView == 'JumpToCategory') {
			jumpToLetterView.showCategories()
		} else if (defView == 'TilesOnly') {
			searchView.showTilesOnly()
		}
	}

	function showTilesOnly() {
		if (!showingAppList) {
			appsView.show(stackView.noTransition)
		}
		config.showSearch = false
	}

	function showSearchView() {
		config.showSearch = true
	}

	states: [
		State {
			name: "searchOnTop"
			when: searchOnTop
			PropertyChanges {
				target: stackViewContainer
				anchors.topMargin: searchField.visible ? searchField.height : 0
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
				anchors.bottomMargin: searchField.visible ? searchField.height : 0
			}
			PropertyChanges {
				target: searchField
				anchors.bottom: searchField.parent.bottom
			}
		}
	]


	Item {
		id: stackViewContainer
		anchors.fill: parent

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

			function show(animation) {
				config.showSearch = true
				if (stackView.currentItem != appsView) {
					stackView.delegate = animation || stackView.panUp
					stackView.push({
						item: appsView,
						replace: true,
					})
				}
				appsView.scrollToTop()
			}
		}

		JumpToLetterView {
			id: jumpToLetterView
			visible: false

			function showLetters() {
				appsModel.order = "alphabetical"
				show()
			}

			function showCategories() {
				appsModel.order = "categories"
				show()
			}

			function show() {
				config.showSearch = true
				if (stackView.currentItem != jumpToLetterView) {
					stackView.delegate = stackView.zoomOut
					stackView.push({
						item: jumpToLetterView,
						replace: true,
					})
				}
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
				config.showSearch = true
				active = true
				item.open(tile)
			}
			readonly property bool isCurrentView: stackView.currentItem == tileEditorView
			onIsCurrentViewChanged: {
				config.isEditingTile = isCurrentView
			}
		}

		SearchStackView {
			id: stackView
			width: config.appAreaWidth
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			initialItem: appsView
		}
	}


	SearchField {
		id: searchField
		visible: !config.isEditingTile && searchView.showSearchField
		height: config.searchFieldHeight
		anchors.left: parent.left
		anchors.right: parent.right

		listView: stackView.currentItem && stackView.currentItem.listView ? stackView.currentItem.listView : []
	}
}
