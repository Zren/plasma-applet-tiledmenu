// Version 7

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Window
import org.kde.kirigami as Kirigami

// https://doc.qt.io/qt-6/qtgraphicaleffects5-index.html
import Qt5Compat.GraphicalEffects as QtGraphicalEffects // TODO Deprecated in Qt6


QQC2.TextField {
	id: colorField
	font.family: "monospace"
	readonly property string defaultText: "#AARRGGBB"
	placeholderText: defaultColor ? defaultColor : defaultText

	onTextChanged: {
		// Make sure the text is:
		//   Empty (use default)
		//   or #123 or #112233 or #11223344 before applying the color.
		if (text.length === 0
			|| (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9))
		) {
			colorField.value = text
		}
	}

	property bool showAlphaChannel: true
	property bool showPreviewBg: true

	property string configKey: ''
	property string defaultColor: ''
	property string value: {
		if (configKey) {
			return plasmoid.configuration[configKey]
		} else {
			return "#000"
		}
	}

	readonly property color defaultColorValue: defaultColor
	readonly property color valueColor: {
		if (value == '' && defaultColor) {
			return defaultColor
		} else {
			return value
		}
	}

	onValueChanged: {
		if (!activeFocus) {
			text = colorField.value
		}
		if (configKey) {
			if (value == defaultColorValue) {
				plasmoid.configuration[configKey] = ""
			} else {
				plasmoid.configuration[configKey] = value
			}
		}
	}

	leftPadding: rightPadding + mouseArea.height + rightPadding

	FontMetrics {
		id: fontMetrics
		font.family: colorField.font.family
		font.italic: colorField.font.italic
		font.pointSize: colorField.font.pointSize
		font.pixelSize: colorField.font.pixelSize
		font.weight: colorField.font.weight
	}
	readonly property int defaultWidth: Math.ceil(fontMetrics.advanceWidth(defaultText))
	implicitWidth: rightPadding + Math.max(defaultWidth, contentWidth) + leftPadding

	// Note: There's a function in Kirigami 5.12:
	// Kirigami.ColorUtils.linearInterpolation(aColor, bColor, balance)
	// but it requires KF5 5.69, while Ubuntu 20.04 currently only has KF5 5.68
	// https://invent.kde.org/frameworks/kirigami/-/blob/master/src/colorutils.h#L88
	// https://invent.kde.org/frameworks/kirigami/-/blob/master/src/colorutils.cpp#L59
	// https://repology.org/project/plasma-framework/versions
	function isTransparent(c) {
		return c.r == 0 && c.g == 0 && c.b == 0 && c.a == 0
	}
	function scaleAlpha(c, factor) {
		return Qt.rgba(c.r, c.g, c.b, c.a * factor)
	}
	function lerpDouble(a, b, balance) {
		return a + (b - a) * balance
	}
	function lerpColor(oneColor, twoColor, balance) {
		if (isTransparent(oneColor)) {
			return scaleAlpha(twoColor, balance)
		}
		if (isTransparent(twoColor)) {
			return scaleAlpha(oneColor, balance)
		}
		var r = lerpDouble(oneColor.r, twoColor.r, balance)
		var g = lerpDouble(oneColor.g, twoColor.g, balance)
		var b = lerpDouble(oneColor.b, twoColor.b, balance)
		var a = lerpDouble(oneColor.a, twoColor.a, balance)
		return Qt.rgba(r, g, b, a)
	}

	MouseArea {
		id: mouseArea
		anchors.leftMargin: parent.rightPadding
		anchors.topMargin: parent.topPadding
		anchors.bottomMargin: parent.bottomPadding
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: height
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: dialogLoader.active = true

		// Color Preview Circle
		Rectangle {
			id: previewBgMask
			visible: false
			anchors.fill: parent
			border.width: 1 * Kirigami.Units.devicePixelRatio
			border.color: "transparent"
			radius: width / 2
		}
		QtGraphicalEffects.ConicalGradient {
			id: previewBgGradient
			visible: colorField.showPreviewBg
			anchors.fill: parent
			angle: 0.0
			gradient: Gradient {
				GradientStop { position: 0.00; color: "white" }
				GradientStop { position: 0.24; color: "white" }
				GradientStop { position: 0.25; color: "#cccccc" }
				GradientStop { position: 0.49; color: "#cccccc" }
				GradientStop { position: 0.50; color: "white" }
				GradientStop { position: 0.74; color: "white" }
				GradientStop { position: 0.75; color: "#cccccc" }
				GradientStop { position: 1.00; color: "#cccccc" }
			}
			source: previewBgMask
		}
		Rectangle {
			id: previewFill
			anchors.fill: parent
			color: colorField.valueColor
			border.width: 1 * Kirigami.Units.devicePixelRatio
			border.color: lerpColor(color, Kirigami.Theme.textColor, 0.5)
			// border.color: Kirigami.ColorUtils.linearInterpolation(color, Kirigami.Theme.textColor, 0.5)
			radius: width / 2
		}
	}

	Loader {
		id: dialogLoader
		active: false
		sourceComponent: ColorDialog {
			id: dialog
			visible: true
			modality: Qt.WindowModal
			options: colorField.showAlphaChannel ? ColorDialog.ShowAlphaChannel : 0
			selectedColor: colorField.valueColor
			onSelectedColorChanged: {
				if (visible) {
					colorField.text = selectedColor
				}
			}
			onAccepted: {
				colorField.text = selectedColor
				dialogLoader.active = false
			}
			onRejected: {
				// This event is also triggered when the user clicks outside the popup modal.
				// TODO Find a way to only trigger when Cancel is clicked.
				colorField.text = initColor
				dialogLoader.active = false
			}

			property color initColor
			Component.onCompleted: {
				initColor = colorField.valueColor
			}
		}
	}
}
