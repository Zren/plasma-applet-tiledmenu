import QtQuick 2.0
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	//--- Sizes
	readonly property int panelIconSize: 24 * PlasmaCore.Units.devicePixelRatio
	readonly property int flatButtonSize: plasmoid.configuration.sidebarButtonSize * PlasmaCore.Units.devicePixelRatio
	readonly property int flatButtonIconSize: plasmoid.configuration.sidebarIconSize * PlasmaCore.Units.devicePixelRatio
	readonly property int sidebarWidth: flatButtonSize
	readonly property int sidebarMinOpenWidth: 200 * PlasmaCore.Units.devicePixelRatio
	readonly property int sidebarRightMargin: 4 * PlasmaCore.Units.devicePixelRatio
	readonly property int sidebarPopupButtonSize: plasmoid.configuration.sidebarPopupButtonSize * PlasmaCore.Units.devicePixelRatio
	readonly property int appListWidth: plasmoid.configuration.appListWidth * PlasmaCore.Units.devicePixelRatio
	readonly property int tileEditorMinWidth: Math.max(350, 350 * PlasmaCore.Units.devicePixelRatio)
	readonly property int minimumHeight: flatButtonSize * 5 // Issue #125

	property bool showSearch: false
	property bool isEditingTile: false
	readonly property int appAreaWidth: {
		if (isEditingTile) {
			return tileEditorMinWidth
		} else if (showSearch) {
			return appListWidth
		} else {
			return 0
		}
	}
	readonly property bool hideSearchField: plasmoid.configuration.hideSearchField
	readonly property int leftSectionWidth: sidebarWidth + sidebarRightMargin + appAreaWidth

	readonly property real tileScale: plasmoid.configuration.tileScale
	readonly property int cellBoxUnits: 80
	readonly property int cellMarginUnits: plasmoid.configuration.tileMargin
	readonly property int cellSizeUnits: cellBoxUnits - cellMarginUnits*2
	readonly property int cellSize: cellSizeUnits * tileScale * PlasmaCore.Units.devicePixelRatio
	readonly property real cellMargin: cellMarginUnits * tileScale * PlasmaCore.Units.devicePixelRatio
	readonly property real cellPushedMargin: cellMargin * 2
	readonly property int cellBoxSize: cellMargin + cellSize + cellMargin
	readonly property int tileGridWidth: plasmoid.configuration.favGridCols * cellBoxSize

	readonly property int favCellWidth: 60 * PlasmaCore.Units.devicePixelRatio
	readonly property int favCellPushedMargin: 5 * PlasmaCore.Units.devicePixelRatio
	readonly property int favCellPadding: 3 * PlasmaCore.Units.devicePixelRatio
	readonly property int favColWidth: ((favCellWidth + favCellPadding * 2) * 2) // = 132 (Medium Size)
	readonly property int favViewDefaultWidth: (favColWidth * 3) * PlasmaCore.Units.devicePixelRatio
	readonly property int favSmallIconSize: 32 * PlasmaCore.Units.devicePixelRatio
	readonly property int favMediumIconSize: 72 * PlasmaCore.Units.devicePixelRatio
	readonly property int favGridWidth: (plasmoid.configuration.favGridCols/2) * favColWidth

	readonly property int searchFieldHeight: plasmoid.configuration.searchFieldHeight * PlasmaCore.Units.devicePixelRatio

	readonly property int popupWidth: {
		if (plasmoid.configuration.fullscreen) {
			return Screen.desktopAvailableWidth
		} else {
			return leftSectionWidth + tileGridWidth
		}
	}
	readonly property int popupHeight: {
		if (plasmoid.configuration.fullscreen) {
			return Screen.desktopAvailableHeight
		} else {
			// implicit Math.floor() when cast as int
			var dPR = PlasmaCore.Units.devicePixelRatio
			var pH3 = plasmoid.configuration.popupHeight
			var pH4 = pH3 * dPR
			var pH5 = Math.floor(pH4)
			// console.log('pH.get', 'dPR='+dPR, 'pH3='+pH3, 'pH4='+pH4, 'pH5='+pH5)
			return pH5
		}
	}
	
	readonly property int menuItemHeight: plasmoid.configuration.menuItemHeight * PlasmaCore.Units.devicePixelRatio
	
	readonly property int searchFilterRowHeight: {
		if (plasmoid.configuration.appListWidth >= 310) {
			return flatButtonSize // 60px
		} else if (plasmoid.configuration.appListWidth >= 250) {
			return flatButtonSize*3/4 // 45px
		} else {
			return flatButtonSize/2 // 30px
		}
	}

	//--- Colors
	readonly property color themeButtonBgColor: {
		if (PlasmaCore.Theme.themeName == "oxygen") {
			return "#20FFFFFF"
		} else {
			return PlasmaCore.Theme.buttonBackgroundColor
		}
	}
	readonly property color defaultTileColor: plasmoid.configuration.defaultTileColor || themeButtonBgColor
	readonly property bool defaultTileGradient: plasmoid.configuration.defaultTileGradient
	readonly property color sidebarBackgroundColor: plasmoid.configuration.sidebarBackgroundColor || PlasmaCore.Theme.backgroundColor
	readonly property color menuItemTextColor2: setAlpha(PlasmaCore.Theme.textColor, 0.6)
	readonly property color favHoverOutlineColor: setAlpha(PlasmaCore.Theme.textColor, 0.8)
	readonly property color flatButtonBgHoverColor: themeButtonBgColor
	readonly property color flatButtonBgColor: Qt.rgba(flatButtonBgHoverColor.r, flatButtonBgHoverColor.g, flatButtonBgHoverColor.b, 0)
	readonly property color flatButtonBgPressedColor: PlasmaCore.Theme.highlightColor
	readonly property color flatButtonCheckedColor: PlasmaCore.Theme.highlightColor

	//--- Style
	// Tiles
	readonly property int tileLabelAlignment: {
		var val = plasmoid.configuration.tileLabelAlignment
		if (val === 'center') {
			return Text.AlignHCenter
		} else if (val === 'right') {
			return Text.AlignRight
		} else { // left
			return Text.AlignLeft
		}
	}
	readonly property int groupLabelAlignment: {
		var val = plasmoid.configuration.groupLabelAlignment
		if (val === 'center') {
			return Text.AlignHCenter
		} else if (val === 'right') {
			return Text.AlignRight
		} else { // left
			return Text.AlignLeft
		}
	}
	
	// App Description Enum (hidden, after, below)
	readonly property bool appDescriptionVisible: plasmoid.configuration.appDescription !== 'hidden'
	readonly property bool appDescriptionBelow: plasmoid.configuration.appDescription == 'below'

	//--- Settings
	// Search
	readonly property bool searchResultsMerged: plasmoid.configuration.searchResultsMerged
	readonly property bool searchResultsCustomSort: plasmoid.configuration.searchResultsCustomSort
	readonly property int searchResultsDirection: plasmoid.configuration.searchResultsReversed ? ListView.BottomToTop : ListView.TopToBottom
	
	//--- Tile Data
	property var tileModel: Base64JsonString {
		configKey: 'tileModel'
		defaultValue: []

		// defaultValue: [
		// 	{
		// 		"x": 0,
		// 		"y": 0,
		// 		"w": 2,
		// 		"h": 2,
		// 		"url": "org.kde.dolphin.desktop",
		// 		"label": "Files",
		// 	},
		// 	{
		// 		"x": 2,
		// 		"y": 1,
		// 		"w": 1,
		// 		"h": 1,
		// 		"url": "virtualbox.desktop",
		// 		"iconFill": true,
		// 	},
		// 	{
		// 		"x": 2,
		// 		"y": 0,
		// 		"w": 1,
		// 		"h": 1,
		// 		"url": "org.kde.ark.desktop",
		// 	},
		// ]
	}
}
