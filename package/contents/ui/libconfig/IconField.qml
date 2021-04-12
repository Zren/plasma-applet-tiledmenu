// Version: 4

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

RowLayout {
	id: configIcon

	default property alias _contentChildren: content.data

	property string configKey: ''
	property alias value: textField.text
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!textField.focus && value != configValue) {
			value = configValue
		}
	}
	property int previewIconSize: Kirigami.Units.iconSizes.medium
	property string defaultValue: ""
	property string placeholderValue: ""

	// Based on org.kde.plasma.kickoff
	QQC2.Button {
		id: iconButton
		padding: Kirigami.Units.smallSpacing

		// KDE QQC2 sets implicitSize to background.implicitSize ignoring padding/inset properties.
		implicitWidth: leftPadding + contentItem.implicitWidth + rightPadding
		implicitHeight: topPadding + contentItem.implicitHeight + bottomPadding

		onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

		contentItem: PlasmaCore.FrameSvgItem {
			id: previewFrame
			imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
					? "widgets/panel-background" : "widgets/background"
			implicitWidth: fixedMargins.left + previewIconSize + fixedMargins.right
			implicitHeight: fixedMargins.top + previewIconSize + fixedMargins.bottom

			PlasmaCore.IconItem {
				anchors.fill: parent
				anchors.leftMargin: previewFrame.fixedMargins.left
				anchors.topMargin: previewFrame.fixedMargins.top
				anchors.rightMargin: previewFrame.fixedMargins.right
				anchors.bottomMargin: previewFrame.fixedMargins.bottom
				source: configIcon.value || configIcon.placeholderValue
				active: iconButton.hovered
			}
		}

		QQC2.Menu {
			id: iconMenu

			// Appear below the button
			y: +parent.height

			QQC2.MenuItem {
				text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Open icon chooser dialog", "Choose...")
				icon.name: "document-open"
				onClicked: dialogLoader.active = true
			}
			QQC2.MenuItem {
				text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Reset icon to default", "Clear Icon")
				icon.name: "edit-clear"
				onClicked: configIcon.value = defaultValue
			}
		}
	}

	ColumnLayout {
		id: content
		Layout.fillWidth: true

		RowLayout {
			QQC2.TextField {
				id: textField
				Layout.fillWidth: true

				text: configIcon.configValue
				onTextChanged: serializeTimer.restart()

				placeholderText: configIcon.placeholderValue

				QQC2.ToolButton {
					icon.name: "edit-clear"
					onClicked: configIcon.value = defaultValue

					anchors.top: parent.top
					anchors.right: parent.right
					anchors.bottom: parent.bottom

					width: height
				}
			}

			QQC2.Button {
				icon.name: "document-open"
				onClicked: dialogLoader.active = true
			}
		}
	}

	Loader {
		id: dialogLoader
		active: false
		sourceComponent: KQuickAddons.IconDialog {
			id: dialog
			visible: true
			modality: Qt.WindowModal
			onIconNameChanged: {
				configIcon.value = iconName
			}
			onVisibleChanged: {
				if (!visible) {
					dialogLoader.active = false
				}
			}
		}
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				plasmoid.configuration[configKey] = configIcon.value
			}
		}
	}
}
