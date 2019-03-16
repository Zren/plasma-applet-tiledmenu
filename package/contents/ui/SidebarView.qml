import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.kquickcontrolsaddons 2.0 // KCMShell

import "Utils.js" as Utils

Item {
	id: sidebarView
	anchors.left: parent.left
	anchors.top: parent.top
	anchors.bottom: parent.bottom
	z: 1

	width: sidebarMenu.width
	Behavior on width { NumberAnimation { duration: 100 } }

	DragAndDrop.DropArea {
		anchors.fill: sidebarMenu

		onDrop: {
			if (event && event.mimeData && event.mimeData.url) {
				var url = event.mimeData.url.toString()
				url = Utils.parseDropUrl(url)
				appsModel.sidebarModel.addFavorite(url, 0)
			}
		}
	}

	SidebarMenu {
		id: sidebarMenu
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom


		ColumnLayout {
			id: sidebarMenuTop
			spacing: 0

			// SidebarItem {
			// 	iconName: 'open-menu-symbolic'
			// 	text: i18n("Menu")
			// 	closeOnClick: false
			// 	onClicked: sidebarMenu.open = !sidebarMenu.open
			// 	zoomOnPush: expanded
			// }

			SidebarViewButton {
				appletIconName: "view-tilesonly"
				text: i18n("Tiles Only")
				onClicked: searchView.showTilesOnly()
				checked: searchView.showingOnlyTiles
			}
			SidebarViewButton {
				appletIconName: "view-list-alphabetically"
				text: i18n("Alphabetical")
				onClicked: appsView.showAppsAlphabetically()
				checked: searchView.showingAppsAlphabetically
			}
			SidebarViewButton {
				appletIconName: 'view-list-categorically'
				text: i18n("Categories")
				onClicked:  appsView.showAppsCategorically()
				checked: searchView.showingAppsCategorically
			}
			// SidebarItem {
			// 	iconName: 'system-search-symbolic'
			// 	text: i18n("Search")
			// 	onClicked: searchResultsView.showDefaultSearch()
			// 	// checked: stackView.currentItem == searchResultsView
			// 	// checkedEdge: Qt.RightEdge
			// 	// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			// }
		}
		ColumnLayout {
			anchors.bottom: parent.bottom
			spacing: 0

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				submenu: userMenu

				SidebarContextMenu {
					id: userMenu

					SidebarItem {
						iconName: 'system-users'
						text: i18n("User Manager")
						onClicked: KCMShell.open('user_manager')
						visible: KCMShell.authorize('user_manager.desktop').length > 0
					}

					SidebarItemRepeater {
						model: appsModel.sessionActionsModel
					}
				}
			}

			SidebarFavouritesView {
				model: appsModel.sidebarModel
				maxHeight: sidebarMenu.height - sidebarMenuTop.height - 2 * config.flatButtonSize
			}

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				text: i18n("Power")
				submenu: powerMenu

				SidebarContextMenu {
					id: powerMenu
					
					SidebarItemRepeater {
						model: appsModel.powerActionsModel
					}
				}
			}
		}

		onFocusChanged: {
			logger.debug('searchView.onFocusChanged', focus)
			if (!focus) {
				open = false
			}
		}
	}


}
