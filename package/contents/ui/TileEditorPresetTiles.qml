import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import "lib"
import "lib/Requests.js" as Requests

// Note: This references a global KCoreAddons.KUser { id: kuser }

GroupBox {
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
		checkForPreset()
	}

	readonly property bool isDesktopFile: endsWith(appObj.appUrl, '.desktop')
	property string steamGameId: ''
	property bool isSteamGameLauncher: !!steamGameId
	property string lutrisGameSlug: ''
	property bool isLutrisGameLauncher: !!lutrisGameSlug

	function endsWith(s, substr) {
		return s.indexOf(substr) == s.length - substr.length
	}

	function checkIfRecognizedLauncher() {
		console.log('checkIfRecognizedLauncher', appObj.appUrl)
		if (!appObj.appUrl) {
			return
		}

		if (!isDesktopFile) {
			return
		}

		Requests.getFile(appObj.appUrl, function(err, data) {
			if (err) {
				console.log('[tiledmenu] checkIfRecognizedLauncher.err', err)
				return
			}

			var desktopFile = Requests.parseMetadata(data)
			checkIfSteamLauncher(desktopFile)
			checkIfLutrisLauncher(desktopFile)

			tileEditorPresetTiles.checkForPreset()
		})
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

		onAppUrlChanged: {
			logger.debug('onAppUrlChanged', appObj.appUrl)
			tileEditorPresetTiles.steamGameId = ''
			tileEditorPresetTiles.checkForPreset()
			tileEditorPresetTiles.checkIfRecognizedLauncher()
		}
	}

	style: PlasmaStyles.GroupBoxStyle {}

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
			property string tileImageUrl: '/home/' + kuser.loginName + '/.local/share/lutris/banners/' + lutrisGameSlug + '.jpg'
			source: (isLutrisGameLauncher && kuser.loginName) ? tileImageUrl : ''
			w: 2
			h: 1
		}
	}
}
