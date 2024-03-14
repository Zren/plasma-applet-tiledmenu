import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.config as KConfig
import org.kde.draganddrop as DragAndDrop
import org.kde.kcmutils as KCM // KCMLauncher
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
				visible: checked || plasmoid.configuration.defaultAppListView == 'TilesOnly'
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
			// 	icon.name: 'system-search-symbolic'
			// 	text: i18n("Search")
			// 	onClicked: searchResultsView.showDefaultSearch()
			// 	// checked: stackView.currentItem == searchResultsView
			// 	// checkedEdge: Qt.RightEdge
			// 	// checkedEdgeWidth: 4 * Screen.devicePixelRatio // Twice as thick as normal
			// }
		}
		ColumnLayout {
			anchors.bottom: parent.bottom
			spacing: 0

			SidebarItem {
				icon.name: kuser.hasFaceIcon ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				submenu: userMenu

				SidebarContextMenu {
					id: userMenu

					SidebarItem {
						icon.name: 'system-users'
						text: i18n("User Manager")
						buttonHeight: config.sidebarPopupButtonSize
						onClicked: KCM.KCMLauncher.open('kcm_users')
						visible: KConfig.KAuthorized.authorizeControlModule('kcm_users')
					}

					SidebarItemRepeater {
						model: appsModel.sessionActionsModel
						buttonHeight: config.sidebarPopupButtonSize
					}
				}
			}

			SidebarFavouritesView {
				model: appsModel.sidebarModel
				maxHeight: sidebarMenu.height - sidebarMenuTop.height - 2 * config.flatButtonSize
			}

			SidebarItem {
				icon.name: 'system-shutdown-symbolic'
				text: i18n("Power")
				submenu: powerMenu

				SidebarContextMenu {
					id: powerMenu
					
					SidebarItemRepeater {
						model: appsModel.powerActionsModel
						buttonHeight: config.sidebarPopupButtonSize
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
