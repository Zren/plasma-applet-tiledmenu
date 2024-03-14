import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

MouseArea {
	id: popup
	property alias searchView: searchView
	property alias appsView: searchView.appsView
	property alias tileEditorView: searchView.tileEditorView
	property alias tileEditorViewLoader: searchView.tileEditorViewLoader
	property alias tileGrid: tileGrid

	RowLayout {
		anchors.fill: parent
		spacing: 0

		Item {
			id: sidebarPlaceholder
			implicitWidth: config.sidebarWidth + config.sidebarRightMargin
			Layout.fillHeight: true
		}

		SearchView {
			id: searchView
			Layout.fillHeight: true
		}

		TileGrid {
			id: tileGrid
			Layout.fillWidth: true
			Layout.fillHeight: true

			cellSize: config.cellSize
			cellMargin: config.cellMargin
			cellPushedMargin: config.cellPushedMargin

			tileModel: config.tileModel.value

			onEditTile: function(tile) { tileEditorViewLoader.open(tile) }

			onTileModelChanged: saveTileModel.restart()
			Timer {
				id: saveTileModel
				interval: 2000
				onTriggered: config.tileModel.save()
			}
		}
		
	}

	SidebarView {
		id: sidebarView
	}

	MouseArea {
		visible: !plasmoid.configuration.tilesLocked && !(plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.RightEdge)
		anchors.top: parent.top
		anchors.right: parent.right
		width: Kirigami.Units.largeSpacing
		height: Kirigami.Units.largeSpacing
		cursorShape: Qt.WhatsThisCursor

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			icon: "help-hint"
			mainText: i18n("Resize?")
			subText: i18n("Meta + Right Click to resize the menu.")
		}
	}

	MouseArea {
		visible: !plasmoid.configuration.tilesLocked && !(plasmoid.location == PlasmaCore.Types.BottomEdge || plasmoid.location == PlasmaCore.Types.RightEdge)
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		width: Kirigami.Units.largeSpacing
		height: Kirigami.Units.largeSpacing
		cursorShape: Qt.WhatsThisCursor

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			icon: "help-hint"
			mainText: i18n("Resize?")
			subText: i18n("Meta + Right Click to resize the menu.")
		}
	}

	onClicked: searchView.searchField.forceActiveFocus()
}
