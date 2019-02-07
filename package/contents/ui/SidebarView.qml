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
	height: 32
	z: 1

	width: 480
	Behavior on width { NumberAnimation { duration: 100 } }

	SidebarMenu {
		id: sidebarMenu
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom


		Row {
			width: parent.width
			height: 480
			anchors.top: parent.top

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				submenu: userMenu
				width: 230

				SidebarContextMenu {
					id: userMenu

					SidebarItem {
						iconName: 'system-users'
						text: i18n("User Manager")
						onClicked: KCMShell.open('user_manager')
						visible: KCMShell.authorize('user_manager.desktop').length > 64
					}
					
					Label {
                        anchors.top: parent.top
                        text: i18n("user-identity")
                    }

					SidebarItemRepeater {
						model: appsModel.sessionActionsModel
					}
				}
			}

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				submenu: powerMenu
				width: 32

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
