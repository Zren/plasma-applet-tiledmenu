import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import QtGraphicalEffects 1.0

Item {
	id: tileItem
	x: modelData.x * cellBoxSize
	y: modelData.y * cellBoxSize
	width: modelData.w * cellBoxSize
	height: modelData.h * cellBoxSize

	function fixCoordinateBindings() {
		x = Qt.binding(function(){ return modelData.x * cellBoxSize })
		y = Qt.binding(function(){ return modelData.y * cellBoxSize })
		z = 0
	}

	AppObject {
		id: appObj
		tile: modelData
	}
	readonly property alias app: appObj.app

	readonly property bool faded: tileGrid.editing || tileMouseArea.isLeftPressed
	readonly property int fadedWidth: width - cellPushedMargin
	opacity: faded ? 0.75 : 1
	scale: faded ? fadedWidth / width : 1
	Behavior on opacity { NumberAnimation { duration: 200 } }
	Behavior on scale { NumberAnimation { duration: 200 } }

	//--- View Start
	TileItemView {
		id: tileItemView
		anchors.fill: parent
		anchors.margins: cellMargin
		width: modelData.w * cellBoxSize
		height: modelData.h * cellBoxSize
		readonly property int minSize: Math.min(width, height)
		readonly property int maxSize: Math.max(width, height)
		hovered: tileMouseArea.containsMouse
	}

	HoverOutlineEffect {
		id: hoverOutlineEffect
		anchors.fill: parent
		anchors.margins: cellMargin
		hoverRadius: {
			if (appObj.isGroup) {
				return tileItemView.maxSize
			} else {
				return tileItemView.minSize
			}
		}
		hoverOutlineSize: tileGrid.hoverOutlineSize
		mouseArea: tileMouseArea
	}
	//--- View End

		MouseArea {
			id: tileMouseArea
			anchors.fill: parent
			hoverEnabled: true
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			cursorShape: editing ? Qt.ClosedHandCursor : Qt.ArrowCursor
			readonly property bool isLeftPressed: pressedButtons & Qt.LeftButton

			property int pressX: -1
			property int pressY: -1
			onPressed: {
				pressX = mouse.x
				pressY = mouse.y
			}

			drag.target: plasmoid.configuration.tilesLocked ? undefined : tileItem
			// drag.onActiveChanged: console.log('drag.active', drag.active)

			// This MouseArea will spam "QQuickItem::ungrabMouse(): Item is not the mouse grabber."
			// but there's no other way of having a clickable drag area.
			onClicked: {
				mouse.accepted = true
				tileGrid.resetDrag()
				if (mouse.button == Qt.LeftButton) {
					if (tileEditorView && tileEditorView.tile) {
						openTileEditor()
					} else if (modelData.url) {
						appsModel.tileGridModel.runApp(modelData.url)
					}
				} else if (mouse.button == Qt.RightButton) {
					contextMenu.open(mouse.x, mouse.y)
				}
			}
		}

	Drag.dragType: Drag.Automatic
	Drag.proposedAction: Qt.MoveAction

	// We use this drag pattern to use the internal drag with events.
	// https://stackoverflow.com/a/24729837/947742
	readonly property bool dragActive: tileMouseArea.drag.active
	onDragActiveChanged: {
		if (dragActive) {
			// console.log("drag started")
			// console.log('onDragStarted', JSON.stringify(modelData), index, tileModel.length)
			tileGrid.startDrag(index)
			// tileGrid.dropOffsetX = 0
			// tileGrid.dropOffsetY = 0
			tileItem.z = 1
			Drag.start()
		} else {
			// console.log("drag finished")
			// console.log('DragArea.onDrop', draggedItem)
			Qt.callLater(tileGrid.resetDrag)
			Qt.callLater(tileItem.fixCoordinateBindings)
			Drag.drop() // Breaks QML context.
			// We need to use callLater to call functions after Drag.drop().
		}
	}

	Loader {
		id: groupEffectLoader
		visible: tileMouseArea.containsMouse
		active: appObj.isGroup && visible
		sourceComponent: Rectangle {
			id: groupOutline
			color: "transparent"
			border.width: 1 * units.devicePixelRatio
			border.color: "#80ffffff"
			y: modelData.h * cellBoxSize
			z: 100
			width: appObj.groupRect.w * cellBoxSize
			height: appObj.groupRect.h * cellBoxSize
		}
	}

	AppContextMenu {
		id: contextMenu
		tileIndex: index
		onPopulateMenu: {
			if (!plasmoid.configuration.tilesLocked) {
				menu.addPinToMenuAction(modelData.url)
			}
			
			appObj.addActionList(menu)

			if (!plasmoid.configuration.tilesLocked) {
				if (modelData.tileType == "group") {
					var menuItem = menu.newMenuItem()
					menuItem.text = i18n("Sort Tiles")
					menuItem.icon = 'sort-name'
					menuItem.onClicked.connect(function(){
						tileGrid.sortGroupTiles(modelData)
					})
				}
				var menuItem = menu.newMenuItem()
				menuItem.text = i18n("Edit Tile")
				menuItem.icon = 'rectangle-shape'
				menuItem.onClicked.connect(function(){
					tileItem.openTileEditor()
				})
			}
		}
	}

	function openTileEditor() {
		tileGrid.editTile(tileGrid.tileModel[index])
	}
	function closeTileEditor() {

	}
}
