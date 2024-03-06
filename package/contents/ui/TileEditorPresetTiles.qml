import QtQuick 2.2
import QtQuick.Layouts 1.0

import "lib/Requests.js" as Requests

// Note: This references a global KCoreAddons.KUser { id: kuser }

TileEditorGroupBox {
	id: tileEditorPresetTiles
	title: "Label"
	Layout.fillWidth: true

	visible: false
	function checkForPreset() {
		var visiblePresets = 0
		for (var i = 0; i < content.children.length; i++) {
			var item = content.children[i]
			var hasImageUrl = item.source && item.source.toString()
			if (hasImageUrl) {
				visiblePresets += 1
			}
		}
		visible = visiblePresets > 0
	}
	Component.onCompleted: {
		checkIfRecognizedLauncher()
	}

	readonly property bool isDesktopFile: endsWith(appObj.appUrl, '.desktop')
	property string steamGameId: ''
	readonly property bool isSteamGameLauncher: !!steamGameId
	property string lutrisGameSlug: ''
	readonly property bool isLutrisGameLauncher: !!lutrisGameSlug

	function endsWith(s, substr) {
		return s.indexOf(substr) == s.length - substr.length
	}

	function resetRecognizedLaunchers() {
		tileEditorPresetTiles.steamGameId = ''
		tileEditorPresetTiles.lutrisGameSlug = ''
	}

	function checkIfRecognizedLauncher() {
		// console.log('checkIfRecognizedLauncher', appObj.appUrl)

		resetRecognizedLaunchers()
		checkForPreset()

		if (!appObj.appUrl) {
			return
		}

		if (!isDesktopFile) {
			return
		}

		// Qt 5.15+ warns that XHR on local file will be removed.
		// Requests.getFile(appObj.appUrl, function(err, data) {
		// 	if (err) {
		// 		console.log('[tiledmenu] checkIfRecognizedLauncher.err', err)
		// 		return
		// 	}

		// 	var desktopFile = Requests.parseMetadata(data)
		// 	checkIfSteamLauncher(desktopFile)
		// 	checkIfLutrisLauncher(desktopFile)

		// 	tileEditorPresetTiles.checkForPreset()
		// })

		checkIfSteamIcon(appObj.iconSource)
		appObj.iconSourceChanged.connect(function(){
			tileEditorPresetTiles.checkIfSteamIcon(appObj.iconSource)
			tileEditorPresetTiles.checkIfLutrisIcon(appObj.iconSource)
			tileEditorPresetTiles.checkForPreset()
		})

		// Lutris does not use game id in icon name. Eg: lutris_overwatch instead of lutris_game_1
	}

	function checkIfSteamIcon(iconSource) {
		var steamIconRegex = /steam_icon_(\d+)/
		var m = steamIconRegex.exec(iconSource)
		if (m) {
			tileEditorPresetTiles.steamGameId = m[1]
		} else {
			tileEditorPresetTiles.steamGameId = '' // Reset
		}
	}

	function checkIfLutrisIcon(iconSource) {
		var lutrisIconRegex = /lutris_([\w\-]+)/
		var m = lutrisIconRegex.exec(iconSource)
		if (m) {
			tileEditorPresetTiles.lutrisGameSlug = m[1]
		} else {
			tileEditorPresetTiles.lutrisGameSlug = '' // Reset
		}
	}

	function checkIfSteamLauncher(desktopFile) {
		var steamCommandRegex = /steam steam:\/\/rungameid\/(\d+)/
		var m = steamCommandRegex.exec(desktopFile['Exec'])
		if (m) {
			tileEditorPresetTiles.steamGameId = m[1]
		} else {
			tileEditorPresetTiles.steamGameId = '' // Reset
		}
	}

	function checkIfLutrisLauncher(desktopFile) {
		var lutrisCommandRegex = /lutris lutris:rungameid\/(\d+)/
		var m1 = lutrisCommandRegex.exec(desktopFile['Exec'])
		var lutrisIconRegex = /^lutris_(.+)$/
		var m2 = lutrisIconRegex.exec(desktopFile['Icon'])
		if (m1 && m2) {
			tileEditorPresetTiles.lutrisGameSlug = m2[1]
		} else {
			tileEditorPresetTiles.lutrisGameSlug = '' // Reset
		}
	}

	Connections {
		target: appObj

		function onAppUrlChanged() {
			logger.debug('onAppUrlChanged', appObj.appUrl)
			tileEditorPresetTiles.checkIfRecognizedLauncher()
		}
	}

	GridLayout {
		id: content
		anchors.left: parent.left
		anchors.right: parent.right
		columns: 2

		//--- Steam
		// 4x2
		TileEditorPresetTileButton {
			filename: 'steam_' + steamGameId + '_4x2.jpg'
			property string tileImageUrl: 'https://steamcdn-a.akamaihd.net/steam/apps/' + steamGameId + '/header.jpg'
			source: isSteamGameLauncher ? tileImageUrl : ''
			w: 4
			h: 2
		}

		// 3x1
		TileEditorPresetTileButton {
			filename: 'steam_' + steamGameId + '_3x1.jpg'
			property string tileImageUrl: 'https://steamcdn-a.akamaihd.net/steam/apps/' + steamGameId + '/capsule_184x69.jpg'
			source: isSteamGameLauncher ? tileImageUrl : ''
			w: 3
			h: 1
		}

		// 5x3 or 3x2
		TileEditorPresetTileButton {
			filename: 'steam_' + steamGameId + '_5x3.jpg'
			property string tileImageUrl: 'https://steamcdn-a.akamaihd.net/steam/apps/' + steamGameId + '/capsule_616x353.jpg'
			source: isSteamGameLauncher ? tileImageUrl : ''
			w: 3
			h: 2
		}

		// 5x2 or 2x1
		TileEditorPresetTileButton {
			filename: 'lutris_' + lutrisGameSlug + '_2x1.jpg'
			// property string tileImageUrl: '/home/' + kuser.loginName + '/.local/share/lutris/banners/' + lutrisGameSlug + '.jpg'
			// source: (isLutrisGameLauncher && kuser.loginName) ? tileImageUrl : ''
			property string tileImageUrl: 'https://lutris.net/games/banner/' + lutrisGameSlug + '.jpg'
			source: (isLutrisGameLauncher) ? tileImageUrl : ''
			w: 2
			h: 1
		}
	}
}
