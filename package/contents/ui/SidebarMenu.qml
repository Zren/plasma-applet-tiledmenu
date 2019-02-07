import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
	id: sidebarMenu
	hoverEnabled: false
	z: 1
	clip: true
	implicitWidth: 480
	implicitHeight: 128
	property bool open: true

	onOpenChanged: {
		if (open) {
			forceActiveFocus()
		} else {
			searchField.forceActiveFocus()
		}
	}

	Rectangle {
		visible: !plasmoid.configuration.sidebarFollowsTheme
		color: config.sidebarBackgroundColor
		opacity: parent.open ? 1 : 0
	}

	Rectangle {
		visible: plasmoid.configuration.sidebarFollowsTheme
		color: theme.backgroundColor
		opacity: parent.open ? 1 : 0
	}
	PlasmaCore.FrameSvgItem {
		visible: plasmoid.configuration.sidebarFollowsTheme
		imagePath: "widgets/frame"
		prefix: "raised"
	}

	property alias showDropShadow: sidebarMenuShadows.visible
	SidebarMenuShadows {
		id: sidebarMenuShadows
		visible: !plasmoid.configuration.sidebarFollowsTheme && sidebarMenu.open
	}
}
