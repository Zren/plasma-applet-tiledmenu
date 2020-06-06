import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.MenuItem {
	id: presetMenuItem
	icon: "list-add-symbolic"
	text: i18n("Add Preset")

	//---
	function addDefault() {
		var pos = tileGrid.findOpenPos(6, 6)
		addProductivity(pos.x, pos.y)
		addExplore(pos.x, pos.y + 3)
	}

	function addProductivity(x, y) {
		var group = tileGrid.addGroup(x, y, {
			label: i18n("Productivity"),
		})
		var writer = addWriter(x, y + 1)
		var calc = addCalc(x + 2, y + 1)
		var mail = addMail(x + 4, y + 1)
	}

	function addExplore(x, y) {
		var group = tileGrid.addGroup(x, y, {
			label: i18n("Explore"),
		})
		var appCenter = addAppCenter(x, y + 1)
		var browser = addWebBrowser(x + 2, y + 1)
		var steam = addSteam(x + 4, y + 1)
	}


	//---
	function addWriter(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'libreoffice-writer.desktop',
			backgroundColor: '#802584b7',
		})
	}
	function addCalc(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'libreoffice-calc.desktop',
			backgroundColor: '#80289769',
		})
	}
	function addMail(x, y) {
		if (appsModel.allAppsModel.hasApp('org.kde.kmail2.desktop')) {
			return addKMail(x, y)
		} else {
			return addGmail(x, y)
		}
	}
	function addKMail(x, y) {
		return tileGrid.addTile(x, y, {
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
		if (appsModel.allAppsModel.hasApp('octopi.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'octopi.desktop',
				label: i18n("Software Center"),
			})
		} else if (appsModel.allAppsModel.hasApp('org.opensuse.YaST.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'org.opensuse.YaST.desktop',
				label: i18n("Software Center"),
			})
		} else if (appsModel.allAppsModel.hasApp('org.kde.discover')) {
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
		if (appsModel.allAppsModel.hasApp('steam.desktop')) {
			return tileGrid.addTile(x, y, {
				url: 'steam.desktop',
			})
		} else {
			return null
		}
	}


	//---
	PlasmaComponents.ContextMenu {
		visualParent: presetMenuItem.action

		PlasmaComponents.MenuItem {
			icon: "libreoffice-startcenter"
			text: i18n("Productivity")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addProductivity(pos.x, pos.y)
			}
		}

		PlasmaComponents.MenuItem {
			icon: "internet-web-browser"
			text: i18n("Explore")
			onClicked: {
				var pos = tileGrid.findOpenPos(6, 3)
				presetMenuItem.addExplore(pos.x, pos.y)
			}
		}

		PlasmaComponents.MenuItem {
			icon: "mail-message"
			text: i18n("Gmail")
			onClicked: {
				var tile = presetMenuItem.addGmail(cellContextMenu.cellX, cellContextMenu.cellY)
				tileGrid.editTile(tile)
			}
		}
	}
}
