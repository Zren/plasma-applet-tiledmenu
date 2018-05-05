import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate

MouseArea {
	id: control
	hoverEnabled: true
	// width: 200
	// height: 200

	property alias hovered: control.containsMouse
	property string iconName: ""
	property string text: ""
	property string tooltip: ""


	property font font: theme.defaultFont
	property alias iconSource: control.iconName
	property real minimumWidth: 0
	property real minimumHeight: 0
	property bool flat: true

	Loader {
		id: styleLoader
		anchors.fill: parent
		asynchronous: true
		source: "AppToolButtonStyle.qml"
		property var control: control

		readonly property int paddingTop: item ? item.paddingTop : 0
		readonly property int paddingLeft: item ? item.paddingLeft : 0
		readonly property int paddingRight: item ? item.paddingRight : 0
		readonly property int paddingBottom: item ? item.paddingBottom : 0
	}

	Item {
		// id: buttonArea
		anchors.fill: parent
		anchors.topMargin: styleLoader.paddingTop
		anchors.leftMargin: styleLoader.paddingLeft
		anchors.rightMargin: styleLoader.paddingRight
		anchors.bottomMargin: styleLoader.paddingBottom

		RowLayout {
			id: buttonContent
			anchors.fill: parent
			spacing: units.smallSpacing

			Layout.preferredHeight: Math.max(units.iconSizes.small, label.implicitHeight)

			PlasmaCore.IconItem {
				id: icon
				source: control.iconName || control.iconSource
				anchors.verticalCenter: parent.verticalCenter

				implicitHeight: label.implicitHeight
				implicitWidth: implicitHeight

				Layout.minimumWidth: valid ? parent.height: 0
				Layout.maximumWidth: Layout.minimumWidth
				visible: valid
				Layout.minimumHeight: Layout.minimumWidth
				Layout.maximumHeight: Layout.minimumWidth
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				active: control.containsMouse
				colorGroup: control.containsMouse ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
			}

			PlasmaComponents.Label {
				id: label
				Layout.minimumWidth: implicitWidth
				text: QtQuickControlsPrivate.StyleHelpers.stylizeMnemonics(control.text)
				font: control.font || theme.defaultFont
				visible: control.text != ""
				Layout.fillWidth: true
				height: parent.height
				color: control.containsMouse ? theme.buttonTextColor : PlasmaCore.ColorScope.textColor
				horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
			}
		}
	}
}
