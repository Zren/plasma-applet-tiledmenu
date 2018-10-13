import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

AppToolButton {
	id: itemDelegate

	width: parent.width
	implicitHeight: row.implicitHeight

	property var parentModel: typeof modelList !== "undefined" && modelList[index] ? modelList[index].parentModel : undefined
	property string modelDescription: model.name == model.description ? '' : model.description // Ignore the Comment if it's the same as the Name.
	property string description: model.url ? modelDescription : '' // 
	property bool isDesktopFile: !!(model.url && endsWith(model.url, '.desktop'))
	property bool showItemUrl: listView.showItemUrl && (!isDesktopFile || listView.showDesktopFileUrl)
	property string secondRowText: showItemUrl && model.url ? model.url : modelDescription
	property bool secondRowVisible: secondRowText
	property string launcherUrl: model.favoriteId || model.url
	property alias iconSource: itemIcon.source
	property int iconSize: model.largeIcon ? listView.iconSize * 2 : listView.iconSize

	function endsWith(s, substr) {
		return s.indexOf(substr) == s.length - substr.length
	}

	// We need to look at the js list since ListModel doesn't support item's with non primitive propeties (like an Image).
	property bool modelListPopulated: !!listView.model.list && listView.model.list.length - 1 >= index
	property var iconInstance: modelListPopulated && listView.model.list[index] ? listView.model.list[index].icon : ""
	Connections {
		target: listView.model
		onRefreshed: {
			// We need to manually trigger an update when we update the model without replacing the list.
			// Otherwise the icon won't be in sync.
			itemDelegate.iconInstance = listView.model.list[index] ? listView.model.list[index].icon : ""
		}
	}

	// Drag (based on kicker)
	// https://github.com/KDE/plasma-desktop/blob/4aad3fdf16bc5fd25035d3d59bb6968e06f86ec6/applets/kicker/package/contents/ui/ItemListDelegate.qml#L96
	// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/draghelper.cpp
	property int pressX: -1
	property int pressY: -1
	property bool dragEnabled: launcherUrl
	function initDrag(mouse) {
		pressX = mouse.x
		pressY = mouse.y
	}
	function shouldStartDrag(mouse) {
		return dragEnabled
			&& pressX != -1 // Drag initialized?
			&& dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y) // Mouse moved far enough?
	}
	function startDrag() {
		widget.draggedFavoriteId = model.favoriteId

		// Requires Plasma 5.9 (probably) https://github.com/KDE/plasma-desktop/commit/85d946b206f6e8a12cf0a03b2386279ff2b0ff1a
		// dragHelper.startDrag(widget, model.url, iconInstance, "favoriteId", model.favoriteId)
		dragHelper.startDrag(widget, model.url || model.favoriteId, iconInstance)

		resetDragState()
	}
	function resetDragState() {
		pressX = -1
		pressY = -1
	}
	onPressed: {
		if (mouse.buttons & Qt.LeftButton) {
			initDrag(mouse)
		}
	}
	onContainsMouseChanged: {
		if (!containsMouse) {
			resetDragState()
		}
	}
	onPositionChanged: {
		if (shouldStartDrag(mouse)) {
			startDrag()
		}
	}

	RowLayout { // ItemListDelegate
		id: row
		anchors.left: parent.left
		anchors.leftMargin: units.smallSpacing
		anchors.right: parent.right
		anchors.rightMargin: units.smallSpacing

		Item {
			Layout.fillHeight: true
			implicitHeight: itemIcon.implicitHeight
			implicitWidth: itemIcon.implicitWidth

			PlasmaCore.IconItem {
				id: itemIcon
				anchors.centerIn: parent
				implicitHeight: itemDelegate.iconSize
				implicitWidth: implicitHeight

				// visible: iconsEnabled

				animated: false
				// usesPlasmaTheme: false
				source: itemDelegate.iconInstance
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			// Layout.fillHeight: true
			Layout.alignment: Qt.AlignVCenter
			spacing: 0

			RowLayout {
				Layout.fillWidth: true
				// height: itemLabel.height

				PlasmaComponents.Label {
					id: itemLabel
					text: model.name
					maximumLineCount: 1
					// elide: Text.ElideMiddle
					height: implicitHeight
				}

				PlasmaComponents.Label {
					Layout.fillWidth: true
					text: !itemDelegate.secondRowVisible ? itemDelegate.description : ''
					color: config.menuItemTextColor2
					maximumLineCount: 1
					elide: Text.ElideRight
					height: implicitHeight // ElideRight causes some top padding for some reason
				}
			}

			PlasmaComponents.Label {
				visible: itemDelegate.secondRowVisible
				Layout.fillWidth: true
				// Layout.fillHeight: true
				text: itemDelegate.secondRowText
				color: config.menuItemTextColor2
				maximumLineCount: 1
				elide: Text.ElideMiddle
				height: implicitHeight
			}
		}

	}

	acceptedButtons: Qt.LeftButton | Qt.RightButton
	onClicked: {
		mouse.accepted = true
		logger.debug('MenuListItem.onClicked', mouse.button, Qt.LeftButton, Qt.RightButton)
		if (mouse.button == Qt.LeftButton) {
			trigger()
		} else if (mouse.button == Qt.RightButton) {
			contextMenu.open(mouse.x, mouse.y)
		}
	}

	function trigger() {
		listView.model.triggerIndex(index)
	}

	// property bool hasActionList: listView.model.hasActionList(index)
	// property var actionList: hasActionList ? listView.model.getActionList(index) : []
	AppContextMenu {
		id: contextMenu
		onPopulateMenu: {
			if (launcherUrl && !plasmoid.configuration.tilesLocked) {
				menu.addPinToMenuAction(launcherUrl)
			}
			if (listView.model.hasActionList(index)) {
				var actionList = listView.model.getActionList(index)
				menu.addActionList(actionList, listView.model, index)
			}
		}
	}

} // delegate: AppToolButton
