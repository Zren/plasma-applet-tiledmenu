import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

StackView {
	id: stackView
	clip: true

	delegate: panUp

	property int zoomDuration: 250
	property int zoomDelta: 100
	property real zoomedInRatio: Math.max(1, stackView.width + zoomDelta * units.devicePixelRatio) / stackView.width
	property real zoomedOutRatio: Math.max(1, stackView.width - zoomDelta * units.devicePixelRatio) / stackView.width

	StackViewDelegate {
		id: noTransition
	}
	StackViewDelegate {
		id: panUp

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
	StackViewDelegate {
		id: zoomOut

		function transitionFinished(properties) {
			properties.exitItem.opacity = 1
			properties.exitItem.scale = 1
		}

		pushTransition: StackViewTransition {
			PropertyAnimation {
				target: enterItem
				property: "opacity"
				easing.type: Easing.InQuad
				from: 0
				to: 1
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: exitItem
				property: "opacity"
				easing.type: Easing.InQuad
				from: 1
				to: 0
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: enterItem
				property: "scale"
				easing.type: Easing.Linear
				from: stackView.zoomedInRatio
				to: 1
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: exitItem
				property: "scale"
				easing.type: Easing.Linear
				from: 1
				to: stackView.zoomedOutRatio
				duration: stackView.zoomDuration
			}
		}
	}
	StackViewDelegate {
		id: zoomIn

		function transitionFinished(properties) {
			properties.exitItem.opacity = 1
			properties.exitItem.scale = 1
		}

		pushTransition: StackViewTransition {
			PropertyAnimation {
				target: enterItem
				property: "opacity"
				easing.type: Easing.InQuad
				from: 0
				to: 1
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: exitItem
				property: "opacity"
				easing.type: Easing.InQuad
				from: 1
				to: 0
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: enterItem
				property: "scale"
				easing.type: Easing.Linear
				from: stackView.zoomedOutRatio
				to: 1
				duration: stackView.zoomDuration
			}
			PropertyAnimation {
				target: exitItem
				property: "scale"
				easing.type: Easing.Linear
				from: 1
				to: stackView.zoomedInRatio
				duration: stackView.zoomDuration
			}
		}
		popTransition: pushTransition
	}
}
