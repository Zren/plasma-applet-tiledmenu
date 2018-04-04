.pragma library

function parseDropUrl(url) {
	var workingDir = Qt.resolvedUrl('.')
	var endsWithDesktop = url.indexOf('.desktop') === url.length - '.desktop'.length
	var isRelativeDesktopUrl = endsWithDesktop && (
		url.indexOf(workingDir) === 0
		// || url.indexOf('file:///usr/share/applications/') === 0
		// || url.indexOf('/.local/share/applications/') >= 0
		|| url.indexOf('/share/applications/') >= 0 // 99% certain this desktop file should be accessed relatively.
	)
	// logger.debug('parseDropUrl', workingDir, endsWithDesktop, isRelativeDesktopUrl)
	// logger.debug('onUrlDropped', 'url', url)
	if (isRelativeDesktopUrl) {
		// Remove the path because .favoriteId is just the file name.
		// However passing the favoriteId in mimeData.url will prefix the current QML path because it's a QUrl.
		var tokens = url.toString().split('/')
		var favoriteId = tokens[tokens.length-1]
		// logger.debug('isRelativeDesktopUrl', tokens, favoriteId)
		return favoriteId
	} else {
		return url
	}
}
