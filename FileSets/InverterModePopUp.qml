////// popup for setting inverter mode from Flow overview

import QtQuick 1.1

Tile {
	id: root

	property bool valid: vItem.value !== undefined
	property alias bind: vItem.bind
	property real localValue: valid ? value : 0
	property alias value: vItem.value
	property alias item: vItem
	property int fontPixelSize: 18
	property bool expanded: false // If the tile is 'expanded', additional touch buttons are shown
	property color buttonColor
	property alias containsMouse: mouseArea.containsMouse
    property int inverterMode

	height: contentHeight + 2
	editable: true

    Component.onCompleted: highlightMode ()

	Behavior on height {
		PropertyAnimation {
			duration: 150
		}
	}

	signal accepted()

	VBusItem {
		id: vItem
        onValueChanged: highlightMode ()
	}

	values:
    [
		Item { width: 1; height: expanded ?  4 : 0; visible: expanded},
        // spacer to expand hidden button over actual button of Multi icon
        TileText
        {
            text: " "
            font.pixelSize: 30
            visible: !expanded
        },
		Column
        {
			width: root.width - 6
			x: 3
			spacing: 4
			visible: expanded

			Button
            {
				id: onButton
				baseColor: inverterMode === 3 ? "black" : root.buttonColor
				pressedColor: root.color
				height: 40
				width: parent.width - 6
				onClicked: changeMode(3)
				content: TileText { text: qsTr("On"); font.bold: true }
			}
            Button
            {
                id: offButton
                baseColor: inverterMode === 4 ? "black" : root.buttonColor
                pressedColor: root.color
                height: 40
                width: parent.width - 6
                onClicked: changeMode(4)
                content: TileText { text: qsTr("Off"); font.bold: true }
            }
            Button
            {
                id: invertOnlyButton
                baseColor: inverterMode === 2 ? "black" : root.buttonColor
                pressedColor: root.color
                height: 40
                width: parent.width - 6
                onClicked: changeMode(2)
                content: TileText { text: qsTr("Inverter\nOnly"); font.bold: true }
            }
            Button 
            {
                id: chargeOnlyButton
                baseColor: inverterMode === 1 ? "black" : root.buttonColor
                pressedColor: root.color
                height: 40
                width: parent.width - 6
                onClicked: changeMode(1)
                content: TileText { text: qsTr("Charger\nOnly"); font.bold: true }
            }
			Button
            {
				id: cancelButton
				baseColor: root.buttonColor
				pressedColor: root.color
				height: 40
				width: parent.width - 2
				onClicked: cancel()
                content: TileText { text: qsTr("Cancel"); font.bold: true }
			}
		}
	]

	function changeMode(newMode)
	{
		if (!root.valid || root.readOnly)
			return

		vItem.setValue(newMode)
        expanded = false
        accepted()
	}

	function cancel()
	{
		root.expanded = false
	}
 
    function highlightMode ()
    {
        if (vItem.valid)
            inverterMode = vItem.value
        else
            inverterMode = 0
    }

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		enabled: !expanded
		onClicked: { root.expanded = true }
	}
}
