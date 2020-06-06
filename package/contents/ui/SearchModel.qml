import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
	id: search
	property alias results: resultModel
	property alias runnerModel: runnerModel

	property string query: ""
	property bool isSearching: query.length > 0
	onQueryChanged: {
		runnerModel.query = search.query
	}

	// KRunner runners are defined in /usr/share/kservices5/plasma-runner-*.desktop
	// To list the runner ids, use:
	//     find /usr/share/kservices5/ -iname "plasma-runner-*.desktop" -print0 | xargs -0 grep "PluginInfo-Name" | sort
	property var filters: []
	onFiltersChanged: {
		runnerModel.deleteWhenEmpty = !runnerModel.deleteWhenEmpty // runnerModel.clear()
		runnerModel.runners = filters
		clearQueryPrefix()
		runnerModel.query = search.query
	}

	Kicker.RunnerModel {
		id: runnerModel

		appletInterface: plasmoid
		favoritesModel: rootModel.favoritesModel
		mergeResults: config.searchResultsMerged

		runners: [] // Empty = All runners.

		// deleteWhenEmpty: isDash
		// deleteWhenEmpty: false

		onRunnersChanged: debouncedRefresh.restart()
		onDataChanged: debouncedRefresh.restart()
		onCountChanged: debouncedRefresh.restart()
	}

	Timer {
		id: debouncedRefresh
		interval: 100
		onTriggered: resultModel.refresh()

		function logAndRestart() {
			// console.log('debouncedRefresh')
			restart()
		}
	}

	SearchResultsModel {
		id: resultModel
	}

	readonly property var defaultFilters: plasmoid.configuration.searchDefaultFilters
	function defaultFiltersContains(runnerId) {
		return defaultFilters.indexOf(runnerId) != -1
	}
	function addDefaultFilter(runnerId) {
		if (!defaultFiltersContains(runnerId)) {
			var l = plasmoid.configuration.searchDefaultFilters
			l.push(runnerId)
			plasmoid.configuration.searchDefaultFilters = l
		}
	}
	function removeDefaultFilter(runnerId) {
		console.log(JSON.stringify(plasmoid.configuration.searchDefaultFilters))
		var i = defaultFilters.indexOf(runnerId)
		if (i >= 0) {
			var l = plasmoid.configuration.searchDefaultFilters
			l.splice(i, 1) // Remove 1 item at index
			plasmoid.configuration.searchDefaultFilters = l
		}
	}

	function isFilter(runnerId) {
		return filters.length == 1 && filters[0] == runnerId
	}
	property bool isDefaultFilter: filters == defaultFilters
	property bool isAppsFilter: isFilter('services')
	property bool isFileFilter: isFilter('baloosearch')
	property bool isBookmarksFilter: isFilter('bookmarks')

	function hasFilter(runnerId) {
		return filters.indexOf(runnerId) >= 0
	}

	function applyDefaultFilters() {
		filters = defaultFilters
	}

	function setQueryPrefix(prefix) {
		// First check to see if there's already a prefix we need to replace.
		var firstSpaceIndex = query.indexOf(' ')
		if (firstSpaceIndex > 0) {
			var firstToken = query.substring(0, firstSpaceIndex)

			if (/^type:\w+$/.exec(firstToken) // baloosearch
				|| /^define$/.exec(firstToken) // Dictionary
			) {
				// replace existing prefix
				query = prefix + query.substring(firstSpaceIndex + 1, query.length)
				return
			}
		}
		
		// If not, just prepend the prefix
		var newQuery = prefix + query
		if (newQuery != query) {
			query = prefix + query
		}
	}

	function clearQueryPrefix() {
		setQueryPrefix('')
	}
}
