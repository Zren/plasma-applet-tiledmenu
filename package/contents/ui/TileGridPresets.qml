import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.MenuItem {
	id: presetMenuItem
	icon: "list-add-symbolic"
	text: i18n("Add Preset")

	//---
	function addProductivity() {
		var pos = tileGrid.findOpenPos(6, 3)
		var group = tileGrid.addGroup(pos.x, pos.y, {
			label: i18n("Productivity"),
		})
		var writer = addWriter(pos.x, pos.y + 1)
		var calc = addCalc(pos.x + 2, pos.y + 1)
		var gmail = addGmail(pos.x + 4, pos.y + 1)
	}

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
	function addGmail(x, y) {
		return tileGrid.addTile(x, y, {
			url: 'https://mail.google.com/mail/u/0/#inbox',
			label: i18n("Gmail"),
			icon: 'mail-message',
			backgroundColor: '#80a73325',
		})
	}


	//---
	PlasmaComponents.ContextMenu {
		visualParent: presetMenuItem.action

		PlasmaComponents.MenuItem {
			icon: "libreoffice-startcenter"
			text: i18n("Productivity")
			onClicked: {
				presetMenuItem.addProductivity()
			}
		}

		PlasmaComponents.MenuItem {
			icon: "mail-message"
			text: i18n("GMail")
			onClicked: {
				var tile = presetMenuItem.addGmail(cellContextMenu.cellX, cellContextMenu.cellY)
				tileGrid.editTile(tile)
			}
		}
	}
}
