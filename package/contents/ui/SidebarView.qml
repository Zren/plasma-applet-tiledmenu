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
	height: 32 * units.devicePixelRatio
	z: 1

		RowLayout {
			id: layout
			spacing: 0
			// height: 480
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			height: parent.height

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				submenu: userMenu
				sidebarMenu: null // Parent SidebarMenu
				expanded: true
				zoomOnPush: false
				Layout.fillWidth: true
				Layout.fillHeight: true

				SidebarContextMenu {
					id: userMenu

					SidebarItem {
						iconName: 'system-users'
						text: i18n("User Manager")
						onClicked: KCMShell.open('user_manager')
						// visible: KCMShell.authorize('user_manager.desktop').length > 0
						visible: false
					}

					SidebarItemRepeater {
						model: appsModel.sessionActionsModel
					}
				}
			}

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				submenu: powerMenu
				sidebarMenu: null // Parent SidebarMenu

				Layout.minimumWidth: 32 * units.devicePixelRatio
				Layout.preferredWidth: Layout.preferredWidth
				Layout.fillHeight: true

				SidebarContextMenu {
					id: powerMenu

					// Align popup to bottom right
					anchors.left: undefined
					anchors.right: parent.right
					
					SidebarItemRepeater {
						model: appsModel.powerActionsModel
					}
				}
			}
		}

}
