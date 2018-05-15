import QtQuick 2.0

Loader {
	id: xdgPathsLoader
	source: "XdgPaths.qml"

	function displayName(type) {
		var key = type.toLowerCase()
		if (key == 'videos') {
			key = 'movies'
		}
		if (xdgPathsLoader.item) {
			return xdgPathsLoader.item[key]
		} else {
			return type
		}
	}
}
