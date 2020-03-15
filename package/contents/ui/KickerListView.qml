import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

GridView {
	id: listView
	width: parent.width
	Layout.fillHeight: true
	clip: true
	cacheBuffer: 200 // Don't unload when scrolling (prevent stutter)

	// snapMode: ListView.SnapToItem
	keyNavigationWraps: true
	highlightMoveDuration: 0
	// highlightResizeDuration: 0

	property bool showItemUrl: true
	property bool showDesktopFileUrl: false
	property int iconSize: 36 * units.devicePixelRatio

	// section.delegate: KickerSectionHeader {}

	delegate: MenuListItem {}

	property var modelList: model ? model.list : []
	
	// currentIndex: 0
	// Connections {
	// 	target: appsModel.allAppsModel
	// 	onRefreshing: {
	// 		console.log('appsList.onRefreshing')
	// 		appsList.model = []
	// 		// console.log('search.results.onRefreshed')
	// 		appsList.currentIndex = 0
	// 	}
	// 	onRefreshed: {
	// 		console.log('appsList.onRefreshed')
	// 		// appsList.model = appsModel.allAppsList
	// 		appsList.model = appsModel.allAppsList
	// 		appsList.modelList = appsModel.allAppsList.list
	// 		appsList.currentIndex = 0
	// 	}
	// }

	// highlight: PlasmaComponents.Highlight {
	// 	visible: listView.currentItem && !listView.currentItem.isSeparator
	// 	width: GridView.view ? GridView.view.width : undefined
	// }

	highlight: Rectangle {
		color: "#22ffffff"
	}
	cellWidth: 200 * units.devicePixelRatio
	cellHeight: listView.iconSize

	// function triggerIndex(index) {
	// 	model.triggerIndex(index)
	// }

	function goUp() {
		return moveCurrentIndexUp()

		if (verticalLayoutDirection == ListView.TopToBottom) {
			decrementCurrentIndex()
		} else { // ListView.BottomToTop
			incrementCurrentIndex()
		}
	}

	function goDown() {
		return moveCurrentIndexDown()

		if (verticalLayoutDirection == ListView.TopToBottom) {
			incrementCurrentIndex()
		} else { // ListView.BottomToTop
			decrementCurrentIndex()
		}
	}

	function skipToMin() {
		currentIndex = Math.max(0, currentIndex - 10)
	}

	function skipToMax() {
		currentIndex = Math.min(currentIndex + 10, count-1)
	}

	function pageUp() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			skipToMin()
		} else { // ListView.BottomToTop
			skipToMax()
		}
	}

	function pageDown() {
		if (verticalLayoutDirection == ListView.TopToBottom) {
			skipToMax()
		} else { // ListView.BottomToTop
			skipToMin()
		}
	}
}
