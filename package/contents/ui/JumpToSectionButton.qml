import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

AppToolButton {
	id: control

	RowLayout {
		id: buttonContent
		anchors.fill: parent
		anchors.topMargin: control.paddingTop
		anchors.leftMargin: control.paddingLeft
		anchors.rightMargin: control.paddingRight
		anchors.bottomMargin: control.paddingBottom

		opacity: control.enabled ? 1 : 0.5
		spacing: Kirigami.Units.smallSpacing

		Layout.preferredHeight: Math.max(Kirigami.Units.iconSizes.small, label.implicitHeight)

		Kirigami.Icon {
			id: icon
			source: control.iconName || control.iconSource

			implicitHeight: label.implicitHeight
			implicitWidth: implicitHeight

			Layout.minimumWidth: valid ? parent.height: 0
			Layout.maximumWidth: Layout.minimumWidth
			visible: valid
			Layout.minimumHeight: Layout.minimumWidth
			Layout.maximumHeight: Layout.minimumWidth
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
			active: control.containsMouse
			// colorGroup: control.containsMouse ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
		}

		PlasmaComponents3.Label {
			id: label
			Layout.minimumWidth: implicitWidth
			text: control.Kirigami.MnemonicData.richTextLabel
			font: control.font || PlasmaCore.Theme.defaultFont
			visible: control.text != ""
			Layout.fillWidth: true
			height: parent.height
			color: control.containsMouse ? PlasmaCore.Theme.buttonTextColor : PlasmaCore.ColorScope.textColor
			horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
		}
	}
}
