// Version 6

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import "." as LibConfig

LibConfig.TextArea {
	id: textArea

	// Load
	function valueToText(value) {
		if (value) {
			return value.join("\n")
		} else {
			return ""
		}
	}

	// Save
	function textToValue(text) {
		if (text) {
			return text.split("\n")
		} else {
			return []
		}
	}

	// Modify
	function prepend(str) {
		textArea.focus = true
		textArea.select(0, 0) // Make sure the text area has focus or we'll enter a loop.
		textArea.text = str + '\n' + textArea.text
	}

	function append(str) {
		textArea.focus = true
		textArea.select(0, 0) // Make sure the text area has focus or we'll enter a loop.
		textArea.text += '\n' + str
	}

	function hasItem(str) {
		var list = textToValue(textArea.text)
		for (var i = 0; i < list.length; i++) {
			if (list[i].trim() == str) {
				return true
			}
		}
		return false
	}

	function selectItem(str) {
		var start = textArea.text.indexOf(str)
		if (start >= 0) {
			textArea.select(start, start + str.length)
		}
	}
}
