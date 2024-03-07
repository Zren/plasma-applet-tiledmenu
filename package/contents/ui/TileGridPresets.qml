import QtQuick 2.0
import org.kde.plasma.extras as PlasmaExtras

PlasmaExtras.MenuItem {
	id: presetMenuItem
	icon: "list-add-symbolic"
	text: i18n("Add Preset")

	//---
	function addDefault() {
		var pos = tileGrid.findOpenPos(6, 6)
		addProductivity(pos.x, pos.y)
		addExplore(pos.x, pos.y + 3)
	}

	function isAppInstalled(appId) {
		return appsModel.allAppsModel.hasApp(appId)
	}

	function addTilePreset(x, y, tileData) {
		var appId = tileData.url
		if (isAppInstalled(appId)) {
			return tileGrid.addTile(x, y, tileData)
		} else {
			return null
		}
	}

	function addGroupPreset(x, y, groupData, tileFnList) {
		var group = tileGrid.addGroup(x, y, groupData)
		var tileX = group.x
		var tileY = y + group.h
		for (var i = 0; i < tileFnList.length; i++) {
			var tileFn = tileFnList[i]
			var tile = tileFn(tileX, tileY)
			if (tile) {
				// TODO: Support Wrap
				tileX += tile.w
			}
		}
	}

	function addProductivity(x, y) {
		addGroupPreset(x, y, {
			label: i18n("Productivity"),
		}, [
			addWriter,
			addCalc,
			addMail,
		])
	}

	function addExplore(x, y) {
		addGroupPreset(x, y, {
			label: i18n("Explore"),
		}, [
			addAppCenter,
			addWebBrowser,
			addSteam,
		])
	}


	//---
	function addWriter(x, y) {
		return addTilePreset(x, y, {
			url: 'libreoffice-writer.desktop',
			backgroundColor: '#802584b7',
		})
	}
	function addCalc(x, y) {
		return addTilePreset(x, y, {
			url: 'libreoffice-calc.desktop',
			backgroundColor: '#80289769',
		})
	}
	function addMail(x, y) {
		var tile = addKMail(x, y)
		if (!tile) {
			tile = addGmail(x, y)
		}
		return tile
	}
	function addKMail(x, y) {
		return addTilePreset(x, y, {
			url: 'org.kde.kmail2.desktop',
		})
	}
	function addGmail(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'https://mail.google.com/mail/u/0/#inbox',
			label: i18n("Gmail"),
			icon: 'mail-message',
			backgroundColor: '#80a73325',
		})
	}

	function addAppCenter(x, y) {
		if (isAppInstalled('octopi.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'octopi.desktop',
				label: i18n("Software Center"),
			})
		} else if (isAppInstalled('org.manjaro.pamac.manager.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'org.manjaro.pamac.manager.desktop',
				// default label is 'Add/Remove Software'
			})
		} else if (isAppInstalled('org.opensuse.yast.Packager.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'org.opensuse.yast.Packager.desktop',
				label: i18n("Software Center"),
			})
		} else if (isAppInstalled('org.kde.discover')) {
			return tileGrid.addTile(x, y, {
				url: 'org.kde.discover',
				label: i18n("Software Center"),
			})
		} else {
			return null
		}
	}

	function addWebBrowser(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'preferred://browser',
		})
	}

	function addSteam(x, y) {
		return addTilePreset(x, y, {
			url: 'steam.desktop',
		})
	}


	//---
	readonly property var presetSubMenu: PlasmaExtras.Menu {
		visualParent: presetMenuItem.action

		PlasmaExtras.MenuItem {
			icon: "libreoffice-startcenter"
			text: i18n("Productivity")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addProductivity(pos.x, pos.y)
			}
		}

		PlasmaExtras.MenuItem {
			icon: "internet-web-browser"
			text: i18n("Explore")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addExplore(pos.x, pos.y)
			}
		}

		PlasmaExtras.MenuItem {
			icon: "mail-message"
			text: i18n("Gmail")
			onClicked: {
				var tile = presetMenuItem.addGmail(cellContextMenu.cellX, cellContextMenu.cellY)
				tileGrid.editTile(tile)
			}
		}
	}
}
