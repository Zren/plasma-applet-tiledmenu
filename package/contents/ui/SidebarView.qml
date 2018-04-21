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


		Column {
			id: sidebarMenuTop
			width: parent.width
			height: childrenRect.height

			SidebarItem {
				iconName: 'open-menu-symbolic'
				text: i18n("Menu")
				closeOnClick: false
				onClicked: sidebarMenu.open = !sidebarMenu.open
				zoomOnPush: expanded
			}
			SidebarItem {
				iconName: 'view-sort-ascending-symbolic'
				text: i18n("Apps")
				onClicked: {
					appsModel.order = "alphabetical"
					appsView.show()
				}
				// checked: stackView.currentItem == appsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			}
			SidebarItem {
				iconName: 'view-list-tree'
				text: i18n("Categories")
				onClicked: {
					appsModel.order = "categories"
					appsView.show()
				}
				// checked: stackView.currentItem == appsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
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
		Column {
			width: parent.width
			height: childrenRect.height
			anchors.bottom: parent.bottom

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				onClicked: userMenu.open = !userMenu.open

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

			// Repeater {
			// 	model: appsModel.sidebarModel
			// 	onCountChanged: console.log(count, 'appsModel.sidebarModel', appsModel.sidebarModel)

			// 	delegate: SidebarItem {

			// 	}

			// }
			SidebarFavouritesView {
				model: appsModel.sidebarModel
				maxHeight: sidebarMenu.height - sidebarMenuTop.height - 2 * config.flatButtonSize
			}

			// SidebarItem {
			// 	iconName: 'folder-open-symbolic'
			// 	text: i18n("File Manager")
			// 	onClicked: appsModel.launch('org.kde.dolphin')
			// }
			// SidebarItem {
			// 	iconName: 'configure'
			// 	text: i18n("Settings")
			// 	onClicked: appsModel.launch('systemsettings')
			// }

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				text: i18n("Power")
				onClicked: powerMenu.open = !powerMenu.open

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
