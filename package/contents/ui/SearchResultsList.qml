import QtQuick

KickerListView { // RunnerResultsList
	id: searchResultsList

	model: []
	delegate: MenuListItem {
		property var runner: search.runnerModel.modelForRow(model.runnerIndex)
		iconSource: runner && runner.data(runner.index(model.runnerItemIndex, 0), Qt.DecorationRole)
	}
	
	section.property: 'runnerName'
	section.criteria: ViewSection.FullString
	// verticalLayoutDirection: config.searchResultsDirection

	Connections {
		target: search.results
		function onRefreshing() {
			searchResultsList.model = []
			// console.log('search.results.onRefreshed')
			searchResultsList.currentIndex = 0
		}
		function onRefreshed() {
			// console.log('search.results.onRefreshed')
			searchResultsList.model = search.results
			// if (searchResultsList.verticalLayoutDirection == Qt.BottomToTop) {
			if (plasmoid.configuration.searchResultsReversed) {
				searchResultsList.currentIndex = searchResultsList.model.count - 1
			} else { // TopToBottom (normal)
				searchResultsList.currentIndex = 0
			}
		}
	}

}
