import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

StackView {
	id: stackView
	clip: true

	delegate: StackViewDelegate {
		pushTransition: StackViewTransition {
			PropertyAnimation {
				target: enterItem
				property: "y"
				from: stackView.height * (searchView.searchOnTop ? -1 : 1)
				to: 0
			}
			PropertyAnimation {
				target: exitItem
				property: "opacity"
				from: 1
				to: 0
			}
		}
		
		function transitionFinished(properties) {
			properties.exitItem.opacity = 1
		}
	}
}
