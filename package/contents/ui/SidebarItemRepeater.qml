import QtQuick

Repeater {
	id: repeater
	property int buttonHeight: config.flatButtonSize
	property int iconSize: config.flatButtonIconSize

	delegate: SidebarItem {
		buttonHeight: repeater.buttonHeight
		iconSize: repeater.iconSize
		icon.name:  model.iconName || model.decoration
		text: model.name || model.display
		sidebarMenu: repeater.parent.parent // SidebarContextMenu { Column { Repeater{} } }
		onClicked: {
			repeater.parent.parent.open = false // SidebarContextMenu { Column { Repeater{} } }
			repeater.model.triggerIndex(index)
		}
	}
}
