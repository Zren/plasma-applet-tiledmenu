import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kquickcontrolsaddons 2.0

import "Utils.js" as Utils

DropArea {
	id: tileGrid

	property int cellSize: 60 * units.devicePixelRatio
	property real cellMargin: 3 * units.devicePixelRatio
	property real cellPushedMargin: 6 * units.devicePixelRatio
	property int cellBoxSize: cellMargin + cellSize + cellMargin
	property int hoverOutlineSize: 2 * units.devicePixelRatio

	property int minColumns: Math.floor(width / cellBoxSize)
	property int minRows: Math.floor(height / cellBoxSize)

	property int maxColumn: 0
	property int maxRow: 0
	property int maxWidth: 0
	property int maxHeight: 0
	property int columns: Math.max(minColumns, maxColumn)
	property int rows: Math.max(minRows, maxRow)


	//--- Drag and Drop properties
	property bool isDragging: false
	property var addedItem: null
	readonly property bool adding: addedItem
	property int draggedIndex: -1
	readonly property var draggedItem: draggedIndex >= 0 ? tileModel[draggedIndex] : null
	property bool editing: isDragging && draggedItem || adding
	property int dropHoverX: -1
	property int dropHoverY: -1
	property int dropOffsetX: 0
	property int dropOffsetY: 0
	readonly property int dropWidth: draggedItem ? draggedItem.w : addedItem ? addedItem.w : 0
	readonly property int dropHeight: draggedItem ? draggedItem.h : addedItem ? addedItem.h : 0
	property bool canDrop: false
	readonly property bool hasDrag: tileGrid.editing && dropHoverX >= 0 && dropHoverY >= 0
	readonly property bool isDraggingGroup: hasDrag && draggedItem && draggedItem.tileType == "group"
	readonly property var draggedGroupRect: {
		if (isDraggingGroup) {
			return getGroupAreaRect(draggedItem)
		} else {
			return null
		}
	}

	//--- Drag and Drop events
	// onContainsDragChanged: console.log('containsDrag', containsDrag)
	onEntered: {
		// console.log('onEntered', drag)
		dragTick(drag)
	}
	onPositionChanged: {
		// console.log('onPositionChanged', drag)
		dragTick(drag)
	}
	onExited: {
		// console.log('onExited')
		resetDragHover()
	}
	onDropped: {
		// console.log('onDropped', drop)
		if (draggedItem) {
			tileGrid.moveTile(draggedItem, dropHoverX, dropHoverY)
			tileGrid.resetDrag()
			// event.accept(Qt.MoveAction)
		} else if (addedItem) {
			addedItem.x = dropHoverX
			addedItem.y = dropHoverY
			tileGrid.tileModel.push(addedItem)
			tileGrid.tileModelChanged()
			tileGrid.resetDrag()
		}
	}

	// Drag and Drop functions
	function resetDragHover() {
		dropHoverX = -1
		dropHoverY = -1
		scrollUpArea.containsDrag = false
		scrollDownArea.containsDrag = false
		addedItem = null
	}
	function resetDrag() {
		resetDragHover()
		isDragging = false
		draggedIndex = -1
	}
	function startDrag(index) {
		draggedIndex = index
		dropHoverX = draggedItem.x
		dropHoverY = draggedItem.y
		isDragging = true
	}

	function tileWithin(tile, x1, y1, x2, y2) {
		var tileX2 = tile.x + tile.w - 1
		var tileY2 = tile.y + tile.h - 1
		return (x1 <= tileX2
			&& tile.x <= x2
			&& y1 <= tileY2
			&& tile.y <= y2
		)
	}

	function getGroupAreaRect(groupTile) {
		var x1 = groupTile.x
		var x2 = groupTile.x + groupTile.w - 1
		var y1 = groupTile.y + groupTile.h
		var y2 = 2000000 // maxint

		// Scan for other groups below this group
		// and adjust y2 to above that group.
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tile.tileType == "group"
				&& tileWithin(tile, x1, y1, x2, y2)
			) {
				// We effectively use Math.min() here as we shrink the box tileWithin uses.
				y2 = tile.y - 1
				// console.log('group found at y =', tile.y, 'y2 set to', y2)
			}
		}

		var lowestTileY = y1
		// console.log('lowestTileY start at y = ', lowestTileY)
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tileWithin(tile, x1, y1, x2, y2)) {
				lowestTileY = Math.max(lowestTileY, tile.y + tile.h - 1)
				// console.log('lowestTileY set to', lowestTileY, JSON.stringify(tile))
			}
		}

		y2 = Math.min(lowestTileY, y2)

		return {
			x1: x1,
			y1: y1,
			x2: x2,
			y2: y2,
			w: x2 - x1 + 1,
			h: y2 - y1 + 1,
		}
	}

	function moveGroup(groupTile, deltaX, deltaY) {
		var area = getGroupAreaRect(groupTile)

		// Move tiles below group label
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tileWithin(tile, area.x1, area.y1, area.x2, area.y2)) {
				tile.x += deltaX
				tile.y += deltaY
			}
		}

		// We call this in moveTile so no need to duplicate work.
		// tileGrid.tileModelChanged()
	}

	function moveTile(tile, cellX, cellY) {
		if (tile.tileType == "group") {
			moveGroup(tile, cellX - tile.x, cellY - tile.y)
		}
		tile.x = cellX
		tile.y = cellY
		tileGrid.tileModelChanged()
	}

	// QQuickDropEvent
	// https://github.com/qt/qtdeclarative/blob/a4aa8d9ade44d75cb5a1d84bd7c1773fadc73095/src/quick/items/qquickdroparea_p.h#L63
	function dragTick(event) {
		// console.log('dragTick', event.x, event.y)
		var dragX = event.x + scrollView.flickableItem.contentX - dropOffsetX
		var dragY = event.y + scrollView.flickableItem.contentY - dropOffsetY
		var modelX = Math.floor(dragX / cellBoxSize)
		var modelY = Math.floor(dragY / cellBoxSize)
		var globalPoint = popup.mapFromItem(tileGrid, event.x, event.y)
		// console.log('onDragMove', event.x, event.y, modelX, modelY, globalPoint)
		scrollUpArea.checkContains(event)
		scrollDownArea.checkContains(event)

		if (draggedItem) {
		} else if (addedItem) {
		} else if (event && event.hasUrls && event.urls) {
			if (event.keys && event.keys.indexOf('favoriteId') >= 0) {
				var url = event.getDataAsString('favoriteId')
				url = Utils.parseDropUrl(url)
			} else {
				var url = event.urls[0]
				// console.log('new addedItem', event.urls, url)
				url = Utils.parseDropUrl(url)
			}
			// console.log('new addedItem')
			// console.log('\t', 'urls', event.urls)
			// console.log('\t', 'url', url)
			// console.log('\t', 'keys', event.keys)
			// for (var i = 0; i < event.keys.length; i++) {
			// 	var key = event.keys[i]
			// 	var value = event.getDataAsString(key)
			// 	console.log('\t', 'mimeData', key, value)
			// }

			addedItem = newTile(url)
			dropHoverX = modelX
			dropHoverY = modelY

			// Firefox/Chromium url dropped
			if (event.keys.indexOf('_NETSCAPE_URL')) {
				var netscapeUrl = event.getDataAsString('_NETSCAPE_URL')
				var tokens = netscapeUrl.split('\n')
				if (tokens.length >= 2) {
					var title = tokens[1].trim()
					if (title) {
						addedItem.label = title
						addedItem.icon = 'internet-web-browser'
					}
				}
			}
		} else {
			return
		}

		dropHoverX = Math.max(0, Math.min(modelX, columns - dropWidth))
		dropHoverY = Math.max(0, modelY)
		canDrop = !hits(dropHoverX, dropHoverY, dropWidth, dropHeight)
	}

	property var hitBox: [] // hitBox[y][x]
	function updateSize() {
		var c = 0;
		var r = 0;
		var w = 1;
		var h = 1;
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			c = Math.max(c, tile.x + tile.w)
			r = Math.max(r, tile.y + tile.h)
			w = Math.max(w, tile.w)
			h = Math.max(h, tile.h)
		}
		// Add extra rows when dragging so we can drop scrolled down
		if (draggedItem) {
			// c += draggedItem.w
			r += draggedItem.h
		}

		// Rebuild hitBox
		var hbColumns = Math.max(minColumns, c)
		var hbRows = Math.max(minRows, r)
		var hb = new Array(hbRows)
		for (var i = 0; i < hbRows; i++) {
			hb[i] = new Array(hbColumns)
		}
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (i == draggedIndex) {
				continue;
			}
			for (var j = tile.y; j < tile.y + tile.h; j++) {
				for (var k = tile.x; k < tile.x + tile.w; k++) {
					hb[j][k] = true
				}
			}
		}

		// Update Properties
		hitBox = hb
		maxColumn = c
		maxRow = r
		maxWidth = w
		maxHeight = h
	}
	function update() {
		var urlList = []
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tile.url) {
				urlList.push(tile.url)
			}
		}
		appsModel.tileGridModel.favorites = urlList
		updateSize()
	}
	onDraggedItemChanged: update()
	onTileModelChanged: update()
	property var tileModel: []


	function hits(x, y, w, h) {
		// console.log('hits', [columns,rows], [x,y,w,h], hitBox)
		for (var j = y; j < y + h; j++) {
			if (j < 0 || j >= hitBox.length) {
				continue; // Should we return true when out of bounds?
			}
			for (var k = x; k < x + w; k++) {
				if (k < 0 || k >= hitBox[j].length) {
					continue; // Should we return true when out of bounds?
				}
				if (hitBox[j][k]) {
					return true
				}
			}
		}
		return false
	}

	function getTileAt(cellX, cellY) {
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tileWithin(tile, cellX, cellY, cellX, cellY)) {
				return tile
			}
		}
		return null
	}

	function getTilesInArea(area) {
		var tileList = []

		// Move tiles below group label
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tileWithin(tile, area.x1, area.y1, area.x2, area.y2)) {
				tileList.push(tile)
			}
		}

		// Sort results by y, then by x
		// tileList.sort(function(a, b) {
		// 	if (a.y == b.y) {
		// 		return b.x - a.x
		// 	} else {
		// 		return b.y - a.y
		// 	}
		// })

		return tileList
	}

	function getTileLabel(tile) {
		if (tile.url) {
			var app = appsModel.tileGridModel.getApp(tile.url)
			var labelText = tile.label || app.display || app.url || ""
			return labelText
		} else {
			return ""
		}
	}
	function sortGroupTiles(groupTile) {
		var area = getGroupAreaRect(groupTile)
		var tileList = getTilesInArea(area)

		var cursorX = groupTile.x
		var cursorY = groupTile.y + groupTile.h
		var rowH = 0
		tileList.sort(function(a, b) {
			var aLabel = getTileLabel(a)
			var bLabel = getTileLabel(b)
			return aLabel.localeCompare(bLabel)
		})

		for (var i = 0; i < tileList.length; i++) {
			var tile = tileList[i]
			var tileX2 = cursorX + tile.w - 1

			// If there's not enough room on this row
			if (tileX2 > area.x2) {
				// Move to the next row
				cursorX = groupTile.x
				cursorY += rowH
			}

			tile.x = cursorX
			tile.y = cursorY
			rowH = Math.max(rowH, tile.h)
			cursorX += tile.w
		}

		// We call this in moveTile so no need to duplicate work.
		tileGrid.tileModelChanged()
	}

	ScrollView {
		id: scrollView
		anchors.fill: parent

		readonly property int scrollTop: flickableItem ? flickableItem.contentY : 0
		readonly property int scrollHeight: flickableItem ? flickableItem.contentHeight : 0
		readonly property int scrollTopAtBottom: viewport ? scrollHeight - viewport.height : 0
		readonly property bool scrollAtTop: scrollTop == 0
		readonly property bool scrollAtBottom: scrollTop >= scrollTopAtBottom

		function scrollBy(deltaY) {
			if (flickableItem) {
				// console.log('scrollHeight', scrollTopAtBottom, scrollHeight, viewport.height)
				flickableItem.contentY = Math.max(0, Math.min(scrollTop + deltaY, scrollTopAtBottom))
			}
		}

		__wheelAreaScrollSpeed: cellBoxSize
		style: ScrollViewStyle {
			transientScrollBars: true
		}
		
		Item {
			id: scrollItem

			width: columns * cellBoxSize
			height: rows * cellBoxSize

			// Rectangle {
			// 	anchors.fill: parent
			// 	color: "#88336699"
			// }

			Repeater {
				id: cellRepeater
				readonly property int cellCount: columns * rows
				onCellCountChanged: {
					if (!isDragging) {
						model = cellCount
					}
				}
				model: 0

				Item {
					id: cellItem
					property int modelX: modelData % columns
					property int modelY: Math.floor(modelData / columns)
					x: modelX * cellBoxSize
					y: modelY * cellBoxSize
					width: cellBoxSize
					height: cellBoxSize

					readonly property bool tileHovered: (hasDrag
						&& dropHoverX <= modelX && modelX < dropHoverX + dropWidth
						&& dropHoverY <= modelY && modelY < dropHoverY + dropHeight
					)
					readonly property bool groupAreaHovered: {
						if (isDraggingGroup) {
							var groupX1 = dropHoverX
							var groupY1 = dropHoverY + dropHeight
							var groupX2 = groupX1 + draggedGroupRect.w - 1
							var groupY2 = groupY1 + draggedGroupRect.h - 1
							return groupX1 <= modelX && modelX <= groupX2
								&& groupY1 <= modelY && modelY <= groupY2
						} else {
							return false
						}
					}

					Rectangle {
						anchors.fill: parent
						anchors.margins: cellMargin
						color: {
							if (cellItem.tileHovered) {
								if (canDrop) {
									return "#88336699"
								} else {
									return "#88880000"
								}
							} else if (cellItem.groupAreaHovered) {
								return "#8848395d" // purple
							} else {
								return "transparent"
							}
						}
						border.width: 1
						border.color: tileGrid.editing ? "#44000000" : "transparent"
					}

					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.RightButton
						onClicked: {
							if (mouse.button == Qt.RightButton) {
								cellContextMenu.cellX = cellItem.modelX
								cellContextMenu.cellY = cellItem.modelY
								var pos = mapToItem(scrollItem, mouse.x, mouse.y) // cellContextMenu is a child of scrollItem
								cellContextMenu.open(pos.x, pos.y)
							}
						}

					}
				}
			}
			PlasmaComponents.ContextMenu {
				id: cellContextMenu
				property int cellX: -1
				property int cellY: -1

				PlasmaComponents.MenuItem {
					icon: "group-new"
					text: i18n("New Group")
					visible: !plasmoid.configuration.tilesLocked
					onClicked: {
						var tile = tileGrid.addGroup(cellContextMenu.cellX, cellContextMenu.cellY)
						tileGrid.editTile(tile)
					}
				}

				TileGridPresets {
					id: tileGridPresets
					visible: !plasmoid.configuration.tilesLocked
				}

				PlasmaComponents.MenuItem {
					icon: plasmoid.configuration.tilesLocked ? "object-unlocked" : "object-locked"
					text: plasmoid.configuration.tilesLocked ? i18n("Unlock Tiles") : i18n("Lock Tiles")
					onClicked: {
						plasmoid.configuration.tilesLocked = !plasmoid.configuration.tilesLocked
					}
				}
			}

			Repeater {
				id: tileModelRepeater
				model: tileModel
				// onCountChanged: console.log('onCountChanged', count)
				
				TileItem {
					id: tileItem
				}
				
			}
		}
	}

	Loader {
		id: tileGridSplashLoader
		anchors.centerIn: parent
		active: tileModel.length == 0 && !tileGrid.editing
		visible: active && width <= parent.width
		source: "TileGridSplash.qml"
		property alias tileGridPresets: tileGridPresets
		property int maxWidth: parent.width
	}

	/* Scroll on hover with drag */
	property int scrollAreaTickDelta: cellBoxSize
	property int scrollAreaTickInterval: 200
	property int scrollAreaSize: Math.min(cellBoxSize * 1.5, scrollView.height / 5) // 20vh or 90pt

	Item {
		id: scrollUpArea
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		height: scrollAreaSize
		property bool active: !scrollView.scrollAtTop
		property bool containsDrag: false
		property bool ticking: active && containsDrag

		function checkContains(event) {
			containsDrag = scrollUpArea.contains(Qt.point(event.x, event.y))
		}

		Timer {
			id: scrollUpTicker
			interval: scrollAreaTickInterval
			repeat: true
			running: parent.ticking
			onTriggered: {
				scrollView.scrollBy(-scrollAreaTickDelta)
			}
		}

		Rectangle {
			anchors.fill: parent
			opacity: parent.ticking ? 1 : 0
			gradient: Gradient {
				GradientStop { position: 0.0; color: theme.highlightColor }
				GradientStop { position: 0.3; color: "transparent" }
			}
		}
	}

	Item {
		id: scrollDownArea
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: scrollAreaSize
		property bool active: !scrollView.scrollAtBottom
		property bool containsDrag: false
		property bool ticking: active && containsDrag

		function checkContains(event) {
			var mouseY = event.y - (parent.height - height)
			containsDrag = scrollDownArea.contains(Qt.point(event.x, mouseY))
		}

		Timer {
			id: scrollDownTicker
			interval: scrollAreaTickInterval
			repeat: true
			running: parent.ticking
			onTriggered: {
				scrollView.scrollBy(scrollAreaTickDelta)
			}
		}

		Rectangle {
			anchors.fill: parent
			opacity: parent.ticking ? 1 : 0
			gradient: Gradient {
				GradientStop { position: 0.7; color: "transparent" }
				GradientStop { position: 1.0; color: theme.highlightColor }
			}
		}
	}

	function newTile(url) {
		return {
			"x": 0,
			"y": 0,
			"w": 2,
			"h": 2,
			"url": url,
		}
	}

	function removeIndex(i) {
		tileModel.splice(i, 1) // remove 1 item at index
		tileModelChanged()
	}

	function removeApp(url) {
		var removedCount = 0
		for (var i = tileModel.length - 1; i >= 0; i--) {
			var tile = tileModel[i]
			if (tile.url == url) {
				removedCount += 1
				tileModel.splice(i, 1) // remove 1 item at index
			}
		}
		if (removedCount > 0) {
			tileModelChanged()
		}
	}

	function findOpenPos(w, h) {
		for (var y = 0; y < rows; y++) {
			for (var x = 0; x < columns - (w-1); x++) {
				if (hits(x, y, w, h))
					continue

				// Room open for
				return {
					x: x,
					y: y,
				}
			}
		}

		// Current grid has no room.
		// Add to new row.
		return {
			x: 0,
			y: rows
		}
	}

	function parseTileXY(tile, x, y) {
		if (typeof x !== "undefined" && typeof y !== "undefined") {
			tile.x = x
			tile.y = y
		} else {
			var openPos = findOpenPos(tile.w, tile.h)
			tile.x = openPos.x
			tile.y = openPos.y
		}
	}
	function addApp(url, x, y) {
		url = Utils.parseDropUrl(url)
		var tile = newTile(url)
		parseTileXY(tile, x, y)
		tileModel.push(tile)
		tileModelChanged()
		return tile
	}

	function hasAppTile(url) {
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tile.url == url) {
				return true
			}
		}
		return false
	}

	function limit(minValue, value, maxValue) {
		return Math.max(minValue, Math.min(value, maxValue))
	}

	function addTile(x, y, props) {
		var tile = newTile("")
		parseTileXY(tile, x, y)
		if (typeof props !== "undefined") {
			var keys = Object.keys(props)
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				var value = props[key]
				tile[key] = value
			}
		}
		tileModel.push(tile)
		tileModelChanged()
		return tile
	}

	function addGroup(x, y, props) {
		var groupProps = {
			tileType: "group",
			label: i18nc("default group label", "Group"),
			w: limit(2, columns-x, 6), // 6 unless we have less columns.
			h: 1,
		}
		if (typeof props !== "undefined") {
			var keys = Object.keys(props)
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				var value = props[key]
				groupProps[key] = value
			}
		}
		return addTile(x, y, groupProps)
	}

	signal editTile(var tile)
}
