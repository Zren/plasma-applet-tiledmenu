// Version 3

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

// Alternative to GroupBox for when we want the title to always be left aligned.
Rectangle {
	id: control
	Layout.fillWidth: true
	default property alias _contentChildren: content.data
	property string label: ""

	color: "#0c000000"
	border.width: 2 * units.devicePixelRatio
	border.color: "#10000000"
	// radius: 5 * units.devicePixelRatio
	property int padding: 8 * units.devicePixelRatio
	implicitHeight: title.height + padding + content.implicitHeight + padding
	property alias spacing: content.spacing

	Label {
		id: title
		visible: control.label
		text: control.label
		font.bold: true
		font.pointSize: 13 * units.devicePixelRatio
		anchors.leftMargin: control.padding
		anchors.rightMargin: control.padding
		// anchors.topMargin: control.padding
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.right: parent.right
		height: visible ? implicitHeight : 0
	}

	ColumnLayout {
		id: content
		anchors.top: title.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: control.padding
		spacing: 5 * units.devicePixelRatio

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		Component.onDestruction: {
			while (children.length > 0) {
				children[children.length - 1].parent = control;
			}
		}
	}

	// Rectangle { anchors.fill: title; border.color: "#f00"; color: "transparent"; border.width: 1; }
	// Rectangle { anchors.fill: content; border.color: "#ff0"; color: "transparent"; border.width: 1; }
}
