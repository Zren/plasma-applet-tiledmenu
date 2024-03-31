// Version 10

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.iconthemes as KIconThemes // IconDialog

RowLayout {
	id: iconField

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
	property alias placeholderValue: textField.placeholderText
	property var presetValues: []

	// Based on org.kde.plasma.kickoff
	QQC2.Button {
		id: iconButton
		padding: Kirigami.Units.smallSpacing
		Layout.alignment: Qt.AlignTop

		// KDE QQC2 sets implicitSize to background.implicitSize ignoring padding/inset properties.
		implicitWidth: leftPadding + contentItem.implicitWidth + rightPadding
		implicitHeight: topPadding + contentItem.implicitHeight + bottomPadding

		onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

		contentItem: KSvg.FrameSvgItem {
			id: previewFrame
			imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
					? "widgets/panel-background" : "widgets/background"
			implicitWidth: fixedMargins.left + previewIconSize + fixedMargins.right
			implicitHeight: fixedMargins.top + previewIconSize + fixedMargins.bottom

			Kirigami.Icon {
				anchors.fill: parent
				anchors.leftMargin: previewFrame.fixedMargins.left
				anchors.topMargin: previewFrame.fixedMargins.top
				anchors.rightMargin: previewFrame.fixedMargins.right
				anchors.bottomMargin: previewFrame.fixedMargins.bottom
				source: iconField.value || iconField.placeholderValue
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
				onClicked: iconField.value = iconField.defaultValue
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

				text: iconField.configValue
				onTextChanged: serializeTimer.restart()

				rightPadding: clearButton.width + Kirigami.Units.smallSpacing

				QQC2.ToolButton {
					id: clearButton
					visible: iconField.configValue != iconField.defaultValue
					icon.name: iconField.defaultValue === "" ? "edit-clear" : "edit-undo"
					onClicked: iconField.value = iconField.defaultValue

					anchors.top: parent.top
					anchors.right: parent.right
					anchors.bottom: parent.bottom

					width: height
				}
			}

			QQC2.Button {
				id: browseButton
				icon.name: "document-open"
				onClicked: dialogLoader.active = true
			}
		}

		Flow {
			Layout.fillWidth: true
			Layout.maximumWidth: Kirigami.Units.gridUnit * 30
			Repeater {
				model: presetValues
				QQC2.Button {
					icon.name: modelData
					text: modelData
					onClicked: iconField.value = modelData
				}
			}
		}
	}

	Loader {
		id: dialogLoader
		active: false
		sourceComponent: KIconThemes.IconDialog {
			id: dialog
			visible: true
			modality: Qt.WindowModal
			onIconNameChanged: {
				iconField.value = iconName
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
				plasmoid.configuration[configKey] = iconField.value
			}
		}
	}
}
