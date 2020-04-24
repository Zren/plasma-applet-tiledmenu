import QtQuick 2.0

QtObject {
	id: appObj

	property var tile: null

	readonly property bool isGroup: tile && tile.tileType == "group"
	readonly property bool isLauncher: !isGroup

	readonly property color defaultBackgroundColor: isGroup ? "transparent" : config.defaultTileColor
	readonly property bool defaultShowIcon: isGroup ? false : true
	readonly property int defaultTileW: isGroup ? 6 : 2
	readonly property int defaultTileH: isGroup ? 1 : 2

	readonly property string favoriteId: tile && tile.url || ''
	readonly property var app: favoriteId ? appsModel.tileGridModel.getApp(favoriteId) : null
	readonly property string appLabel: app ? app.display : ""
	readonly property string appUrl: app ? app.url : ""
	readonly property var appIcon: app ? app.decoration : null
	readonly property string labelText: tile && tile.label || appLabel || appUrl || ""
	readonly property var iconSource: tile && tile.icon || appIcon
	readonly property bool iconFill: tile && typeof tile.iconFill !== "undefined" ? tile.iconFill : false
	readonly property bool showIcon: tile && typeof tile.showIcon !== "undefined" ? tile.showIcon : defaultShowIcon
	readonly property bool showLabel: tile && typeof tile.showLabel !== "undefined" ? tile.showLabel : true
	readonly property color backgroundColor: tile && typeof tile.backgroundColor !== "undefined" ? tile.backgroundColor : defaultBackgroundColor
	readonly property string backgroundImage: tile && typeof tile.backgroundImage !== "undefined" ? tile.backgroundImage : ""
	readonly property bool backgroundGradient: tile && typeof tile.gradient !== "undefined" ? tile.gradient : config.defaultTileGradient

	readonly property int tileX: tile && typeof tile.x !== "undefined" ? tile.x : 0
	readonly property int tileY: tile && typeof tile.y !== "undefined" ? tile.y : 0
	readonly property int tileW: tile && typeof tile.w !== "undefined" ? tile.w : defaultTileW
	readonly property int tileH: tile && typeof tile.h !== "undefined" ? tile.h : defaultTileH


	// onTileChanged: console.log('onTileChanged', JSON.stringify(tile))
	// onAppLabelChanged: console.log('onAppLabelChanged', appLabel)

	function hasActionList() {
		return app ? appsModel.tileGridModel.indexHasActionList(app.indexInModel) : false
	}

	function getActionList() {
		return app ? appsModel.tileGridModel.getActionListAtIndex(app.indexInModel) : []
	}

	function addActionList(menu) {
		if (hasActionList()) {
			var actionList = getActionList()
			menu.addActionList(actionList, appsModel.tileGridModel, appObj.app.indexInModel)
		}
	}

	readonly property var groupRect: {
		if (isGroup) {
			return tileGrid.getGroupAreaRect(tile)
		} else {
			return null
		}
	}
	property Connections tileGridConnection: Connections {
		target: tileGrid
		onTileModelChanged: {
			if (appObj.isGroup) {
				appObj.groupRectChanged()
			}
		}
	}
}
