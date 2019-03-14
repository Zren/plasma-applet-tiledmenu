import QtQuick 2.2
import QtQuick.Layouts 1.0

Item {
	id: presetTileButton
	Layout.fillWidth: parent.width
	Layout.preferredHeight: image.paintedHeight

	visible: source
	property alias source: image.source
	property string filename: 'temp.jpg'
	property int w: 0
	property int h: 0

	Image {
		id: image
		anchors.centerIn: parent
		width: Math.min(parent.width, sourceSize.width)

		fillMode: Image.PreserveAspectFit
	}

	HoverOutlineEffect {
		id: hoverOutlineEffect
		anchors.fill: image
		hoverRadius: Math.min(width, height)
		property alias control: mouseArea
	}

	MouseArea {
		id: mouseArea
		anchors.fill: image
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton
		cursorShape: Qt.ArrowCursor

		onClicked: presetTileButton.select()
	}

	function getDownloadDir() {
		// plasmoid.downloadPath() will create this folder.
		// ~/Downloads/Plasma/com.github.zren.tiledmenu/
		// I litters the Downloads folder... which isn't ideal.
		return plasmoid.downloadPath()

		// TODO: Download to ~/.local/share since it's hidden.
		// Note, this folder does not exist! So we need to create it somehow.
		// Maybe we could run `mkdir -p /path/to/folder` using the exec dataengine.

		// Requires: import Qt.labs.platform 1.0
		// ~/.local/share/
		// var localDownloadDir = StandardPaths.writableLocation(StandardPaths.GenericDataLocation)
		// console.log('localDownloadDir', localDownloadDir)

		// Remove file:// URL scheme
		// localFilepath = localDownloadDir.substr('file://'.length)

		// ~/.local/share/plasma_com.github.zren.tiledmenu
		// var tiledMenuDir = localDownloadDir + '/' + 'plasma_' + plasmoid.pluginName
		// console.log('tiledMenuDir', tiledMenuDir)
		// return tiledMenuDir
	}

	function resizeTile() {
		var sizeChanged = false
		if (presetTileButton.w > 0) {
			appObj.tile.w = presetTileButton.w
			sizeChanged = true
		}
		if (presetTileButton.h > 0) {
			appObj.tile.h = presetTileButton.h
			sizeChanged = true
		}
		if (sizeChanged) {
			appObj.tileChanged()
			tileGrid.tileModelChanged()
		}
	}

	function setTileBackgroundImage(filepath) {
		backgroundImageField.text = filepath
		labelField.checked = false
		iconField.checked = false
	}

	function select() {
		logger.debug('select', source)

		var sourceFilepath = '' + source // cast to string
		var isLocalFilepath = sourceFilepath.indexOf('file://') == 0 || sourceFilepath.indexOf('/') == 0
		if (isLocalFilepath) {
			presetTileButton.setTileBackgroundImage(source)
			presetTileButton.resizeTile()
		} else {
			var tiledMenuDir = getDownloadDir()
			var localFilepath = tiledMenuDir + filename
			logger.debug('localFilepath', localFilepath)

			// Save tile image to file
			logger.debug('grabToImage.start')
			image.grabToImage(function(result){
				logger.debug('grabToImage.done', result, result.url)
				result.saveToFile(localFilepath)
				presetTileButton.setTileBackgroundImage(localFilepath)
				presetTileButton.resizeTile()
			}, image.sourceSize)
		}
	}

}
