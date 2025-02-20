////// MODIFIED to show:
//////  tanks in a row along bottom
//////  PV voltage and current and DC power current (up to 2 MPPTs with tanks and temps or 3 without)
//////  PV inverter power (up to 2 with tanks and temps or 3 without)
//////  voltage, current, frequency in AC tiles (plus current limit for AC input)
//////  time of day
//////  current in DC Loads
//////  remaining time in Battery tile
//////  bar graphs on AC in/out and Multi
//////  detail pages for all tiles
//////  bar gauge on PV Charger tile
//////  add support for VE.Direct inverters

import QtQuick 1.1
import "utils.js" as Utils
////// ADDED to show tanks
import com.victron.velib 1.0



OverviewPage {
	id: root

    property color detailColor: "#b3b3b3"
    property real touchTargetOpacity: 0.3
    property int touchArea: 40
    property bool showTargets: helpTimer.running
    property variant sys: theSystem
    property bool isMulti: numberOfMultis === 1
    property bool hasInverter: isMulti || numberOfInverters === 1
    property bool hasAcInput: isMulti
    property bool hasAcOutSystem: _hasAcOutSystem.value === 1
    property bool hasDcSystem: hasDcSys.value > 0
	property bool hasAcSolarOnAcIn1: sys.pvOnAcIn1.power.valid
	property bool hasAcSolarOnAcIn2: sys.pvOnAcIn2.power.valid
	property bool hasAcSolarOnIn: hasAcSolarOnAcIn1 || hasAcSolarOnAcIn2
	property bool hasAcSolarOnOut: sys.pvOnAcOut.power.valid
	property bool hasAcSolar: hasAcSolarOnIn || hasAcSolarOnOut
	property bool hasDcSolar: sys.pvCharger.power.valid
	property bool hasDcAndAcSolar: hasAcSolar && hasDcSolar
////// ADDED to show tanks
    property int bottomOffset: 45
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTemps: 0
//////// added/modified for control show/hide gauges, tanks and temps from menus
    property int tankCount: showTanksEnable ? tankModel.rowCount : 0
    property int tempCount: showTempsEnable ? numberOfTemps : 0
    property int tankTempCount: tankCount + tempCount
    property bool showTanks: showTanksEnable ? showStatusBar ? false : tankCount > 0 ? true : false : false
    property bool showTemps: showTempsEnable ? showStatusBar ? false : tempCount > 0 ? true : false : false
    property bool showTanksTemps: showTanks || showTemps
    property int compactThreshold: 45   // height below this will be compacted vertically
    property int batteryHeight: 91
    property bool compact: showTanks && showTemps && tankTempCount > 4
    property int tanksHeight: compact ? 22 : 45

//////// add for PV CHARGER voltage and current
    property string pvChargerPrefix1: ""
    property string pvChargerPrefix2: ""
    property string pvChargerPrefix3: ""
    property int numberOfPvChargers: 0
//////// add for PV INVERTER power
    property string pvInverterPrefix1: ""
    property string pvInverterPrefix2: ""
    property string pvInverterPrefix3: ""
    property int numberOfPvInverters: 0

    property int numberOfMultis: 0
    property string multiPrefix: ""
//////// add for VE.Direct inverters
    property int numberOfInverters: 0
    property string inverterService: ""

//////// added for control show/hide gauges, tanks and temps from menus
    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
    VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
    property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
    VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
    property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

//////// added to control time display
    VBusItem { id: timeFormatItem; bind: Utils.path(guiModsPrefix, "/TimeFormat") }
    property string timeFormat: getTimeFormat ()
    
    function getTimeFormat ()
    {
        if (!timeFormatItem.valid || timeFormatItem.value === 0)
            return ""
        else if (timeFormatItem.value === 2)
            return "h:mm ap"
        else
            return "hh:mm"
    }

//////// add to display PV charger voltage and current
    VBusItem { id: pvName1;  bind: Utils.path(pvChargerPrefix1, "/CustomName") }
    VBusItem { id: pvVoltage1;  bind: Utils.path(pvChargerPrefix1, "/Pv/V") }
    VBusItem { id: pvCurrent1; bind: Utils.path(pvChargerPrefix1, "/Pv/I") }
    VBusItem { id: pvPower1; bind: Utils.path(pvChargerPrefix1, "/Yield/Power") }

    VBusItem { id: pvName2;  bind: Utils.path(pvChargerPrefix2, "/CustomName") }
    VBusItem { id: pvVoltage2;  bind: Utils.path(pvChargerPrefix2, "/Pv/V") }
    VBusItem { id: pvCurrent2; bind: Utils.path(pvChargerPrefix2, "/Pv/I") }
    VBusItem { id: pvPower2; bind: Utils.path(pvChargerPrefix2, "/Yield/Power") }

    VBusItem { id: pvName3;  bind: Utils.path(pvChargerPrefix3, "/CustomName") }
    VBusItem { id: pvVoltage3;  bind: Utils.path(pvChargerPrefix3, "/Pv/V") }
    VBusItem { id: pvCurrent3; bind: Utils.path(pvChargerPrefix3, "/Pv/I") }
    VBusItem { id: pvPower3; bind: Utils.path(pvChargerPrefix3, "/Yield/Power") }

    VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }

//////// add to display PV Inverter power
    VBusItem { id: pvInverterPower1; bind: Utils.path(pvInverterPrefix1, "/Ac/Power") }
    VBusItem { id: pvInverterName1; bind: Utils.path(pvInverterPrefix1, "/CustomName") }
    VBusItem { id: pvInverterPower2; bind: Utils.path(pvInverterPrefix2, "/Ac/Power") }
    VBusItem { id: pvInverterName2; bind: Utils.path(pvInverterPrefix2, "/CustomName") }
    VBusItem { id: pvInverterPower3; bind: Utils.path(pvInverterPrefix3, "/Ac/Power") }
    VBusItem { id: pvInverterName3; bind: Utils.path(pvInverterPrefix3, "/CustomName") }

    VBusItem { id: _hasAcOutSystem; bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem" }
    VBusItem { id: hasDcSys; bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem" }

    Component.onCompleted: { discoverServices(); helpTimer.running = true }

	title: qsTr("Overview")

	OverviewBox {
		id: acInBox
        visible: hasAcInput
		width: 148
		height: showStatusBar ? 100 : 120
		title: getAcSourceName(sys.acSource)
		titleColor: "#E74c3c"
		color: "#C0392B"
		anchors {
			top: multi.top
			left: parent.left; leftMargin: 10
		}

		values:	OverviewAcValuesEnhanced {
			connection: sys.acInput
		}

		MbIcon {
			iconId: getAcSourceIcon(sys.acSource)
			anchors {
				bottom: parent.bottom
				left: parent.left; leftMargin: 2
			}
			opacity: 0.5
		}
////// add power bar graph
        PowerGauge
        {
            id: acInBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acInput
            maxForwardPowerParameter: "" // handled internally - uses input current limit and AC input voltage
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
            show: showGauges && hasAcInput
        }
	}


	MultiEnhanced {
		id: multi
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top; topMargin: 3
		}
        inverterService: root.inverterService
////// add power bar graph
        PowerGaugeMulti
        {
            id: multiBar
            width: multi.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 23
                horizontalCenter: parent.horizontalCenter
            }
            inverterService: root.inverterService
            show: showGauges
        }
	}

////// ADDED to show time inside inverter icon
    Timer {
        id: wallClock
        running: timeFormat != ""
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: time = Qt.formatDateTime(new Date(), timeFormat)
        property string time
    }
    TileText
    {
        text: wallClock.time
        font.pixelSize: 18
        anchors
        {
            top: multi.top; topMargin: 96
            horizontalCenter: multi.horizontalCenter
        }
        show: wallClock.running
    }

	OverviewBox {
		id: acLoadBox
        visible: hasAcOutSystem
		title: qsTr("AC Loads")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: 148
		height: showStatusBar ? 80 : 102

		anchors {
			right: parent.right; rightMargin: 10
			top: multi.top
		}

		values: OverviewAcValuesEnhanced {
			connection: sys.acLoad
		}
////// add power bar graph
        PowerGauge
        {
            id: acLoadBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acLoad
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
            show: showGauges && hasAcOutSystem
        }
	}

	Battery {
		id: battery
        width: acInBox.width
		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
////// add battery current bar graph
        PowerGaugeBattery
        {
            id: batteryBar
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 52
                horizontalCenter: parent.horizontalCenter
            }
            show: showGauges
        }

////// MODIFIED to show tanks
        height: batteryHeight + 5
		anchors {
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5;
			left: parent.left; leftMargin: 10
		}
		values: Column {
			width: parent.width

			TileText {
				text: sys.battery.soc.value === undefined ? "--" : sys.battery.soc.format (0)
				font.pixelSize: 25
			}
			TileText {
				text: sys.battery.power.format(0)
			}
            TileText {
                text: " "
                font.pixelSize: 6
            }
			TileText {
				text: sys.battery.voltage.format(1) + "   " + sys.battery.current.format(1)
			}
            TileText {
                text: {
                    if (timeToGo.valid)
                        return "Remain: " + Utils.secondsToString(timeToGo.value)
                    else
                        return "Remain: ∞"
                }
            }
        }
	}

     VBusItem {
        id: maxDcLoad
        bind: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
    }
     VBusItem {
        id: maxDcCharge
        bind: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
    }

	OverviewBox {
		id: dcSystemBox
////// wider to make room for current
		width: multi.width + 20
		height: 45
        visible: hasDcSystem
        title:
        {
            var dcLoad, dcCharge
            if (maxDcLoad.valid && maxDcLoad.value != 0)
                dcLoad = true
            else
                dcLoad = false
            if (maxDcCharge.valid && maxDcCharge.value != 0)
                dcCharge = true
            else
                dcCharge = false
            if (dcLoad && ! dcCharge)
                qsTr ("DC Loads")
            else if ( ! dcLoad && dcCharge)
                qsTr ("DC Charge")
            else
                qsTr ("DC System")
        }

		anchors {
			horizontalCenter: multi.horizontalCenter
            horizontalCenterOffset: 2
////// MODIFIED to show tanks
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}

        values: TileText {
            anchors.centerIn: parent
////// modified to show current
            text: dcSystemText ()
        }
    }

    function dcSystemText ()
    {
        if (hasDcSystem)
        {
            var current = sys.dcSystem.power.value / sys.battery.voltage.value
            if (Math.abs (current) <= 100)
                return sys.dcSystem.power.format(0) + " " + current.toFixed(1) + "A"
            else
                return sys.dcSystem.power.format(0) + " " + current.toFixed(0) + "A"
        }
        else
            return "--"
    }

	OverviewSolarChargerEnhanced {
		id: blueSolarCharger

////// MODIFIED to show tanks & provide extra space if not
        height: hasDcAndAcSolar ? 65 : showTanksTemps ? batteryHeight + 20 : 114 + bottomOffset
        width: 148
		title: qsTr("PV Charger")
////// MODIFIED - always hide icon peaking out from under PV tile
		showChargerIcon: false
		visible: hasDcSolar

		anchors {
			right: root.right; rightMargin: 10
            bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}
////// moved sun icon here from OverviewSolarChager so it can be put below text, etc
        MbIcon {
            iconId: "overview-sun"
            anchors {
                bottom: parent.bottom
                right: parent.right; rightMargin: 2
            }
            opacity: 0.5
        }

//////// add voltage and current
		values: 
        [
            TileText {
                y: 8
                text: sys.pvCharger.power.format(0)
                font.pixelSize: 19
            },
            TileText {
                y: 29
                text: numberOfPvChargers >= 1 && pvName1.valid ? pvName1.text : " "
                visible: numberOfPvChargers >= 1 && pvName1.valid
            },
            TileText {
                y: 45
                text:
                {
                    var voltageText, currentText
                    if (root.numberOfPvChargers < 1)
                        return " "
                    else
                    {
                        if (pvVoltage1.valid)
                            voltageText = pvVoltage1.text
                        else
                            voltageText = "??V"
                        if (pvCurrent1.valid)
                            currentText = pvCurrent1.text
                        else if (pvPower1.valid)
                            currentText =  (pvPower1.value / pvVoltage1.value).toFixed (1) + "A"
                        else
                            currentText = "??A"
                        return voltageText + " " + currentText
                    }
                }
                font.pixelSize: 15
                visible: numberOfPvChargers > 0
            },
            TileText {
                y: 61
                text: numberOfPvChargers >= 2 && pvName2.valid ? pvName2.text : " "
                visible: numberOfPvChargers >= 2 && pvName2.valid
            },
            TileText {
                y: 75
                text:
                {
                    var voltageText, currentText
                    if (numberOfPvChargers < 2)
                        return ""
                    else
                    {
                        if (pvVoltage2.valid)
                            voltageText = pvVoltage2.text
                        else
                            voltageText = "??V"
                        if (pvCurrent2.valid)
                            currentText = pvCurrent2.text
                        else if (pvPower2.valid)
                            currentText =  (pvPower2.value / pvVoltage2.value).toFixed (1) + "A"
                        else
                            currentText = "??A"
                        return voltageText + " " + currentText
                    }
                }
                font.pixelSize: 15
                visible: numberOfPvChargers >= 2
            },
            TileText {
                y: 91
                text: numberOfPvChargers >= 3 && pvName3.valid ? pvName3.text : " "
                visible: numberOfPvChargers >= 3 && pvName3.valid && ! showTanksTemps
            },
            TileText {
                y: 105
                text:
                {
                    var voltageText, currentText
                    if (numberOfPvChargers < 3)
                        return ""
                    else
                    {
                        if (pvVoltage3.valid)
                            voltageText = pvVoltage3.text
                        else
                            voltageText = "??V"
                        if (pvCurrent3.valid)
                            currentText = pvCurrent3.text
                        else if (pvPower3.valid)
                            currentText =  (pvPower3.value / pvVoltage3.value).toFixed (1) + "A"
                        else
                            currentText = "??A"
                        return voltageText + " " + currentText
                    }
                }
                font.pixelSize: 15
                visible: numberOfPvChargers >= 3 && ! showTanksTemps
            }
        ]
////// add power bar graph
        PowerGauge
        {
            id: pvChargerBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvCharger
            show: showGauges && hasDcSolar
        }
	}

    OverviewSolarInverter {
        id: pvInverter
////// MODIFIED to show tanks & provide extra space if not
        height: hasDcAndAcSolar ? 65 : showTanksTemps ? batteryHeight + 20 : 114 + bottomOffset
        width: 148
        title: qsTr("PV Inverter")
        showInverterIcon: !hasDcAndAcSolar
        visible: hasAcSolar

        anchors {
            right: root.right; rightMargin: 10;
            bottom: root.bottom; bottomMargin: hasDcAndAcSolar ? 75 : 5
        }

        OverviewAcValuesEnhanced {
            connection: hasAcSolarOnOut ? sys.pvOnAcOut : hasAcSolarOnAcIn1 ? sys.pvOnAcIn1 : sys.pvOnAcIn2
            visible: !coupledPvAc.visible
        }

//////// add individual PV inverter powers
        values:
        [
            TileText {
                id: coupledPvAc

                property double pvInverterOnAcOut: sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
                property double pvInverterOnAcIn1: sys.pvOnAcIn1.power.valid ? sys.pvOnAcIn1.power.value : 0
                property double pvInverterOnAcIn2: sys.pvOnAcIn2.power.valid ? sys.pvOnAcIn2.power.value : 0

                y: 10
                text: (pvInverterOnAcOut + pvInverterOnAcIn1 + pvInverterOnAcIn2).toFixed(0) + "W"
                font.pixelSize: hasDcAndAcSolar ? 20 : 25
                visible: hasDcAndAcSolar || (hasAcSolarOnIn && hasAcSolarOnOut) || (hasAcSolarOnAcIn1 && hasAcSolarOnAcIn2)
            },
            TileText {
                y: 31
                text: pvInverterName1.valid ? pvInverterName1.text : "-"
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1
            },
            TileText {
                y: 47
                text: pvInverterPower1.valid ? pvInverterPower1.text : "--"
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1
            },
            TileText {
                y: 63
                text: pvInverterName2.valid ? pvInverterName2.text : "-"
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1
            },
            TileText {
                y: 77
                text: pvInverterPower2.valid ? pvInverterPower2.text : "--"
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1
            },
            TileText {
                y: 93
                text: pvInverterName3.valid ? pvInverterName3.text : "-"
                visible: !hasDcAndAcSolar && numberOfPvInverters > 2 && ! showTanksTemps
            },
            TileText {
                y: 107
                text: pvInverterPower3.valid ? pvInverterPower3.text : "--"
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 2 && ! showTanksTemps
            }
        ]
////// add power bar graph
        PowerGauge
        {
            id: pvInverterBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
            connection: hasAcSolarOnOut ? sys.pvOnAcOut : hasAcSolarOnAcIn1 ? sys.pvOnAcIn1 : sys.pvOnAcIn2
            show: showGauges && hasAcSolar && !hasDcAndAcSolar
        }
    }

	OverviewConnection {
		id: acInToMulti
        visible: hasAcInput
		ballCount: 2
		path: straight
		active: root.active
		value: flow(sys.acInput ? sys.acInput.power : 0)

		anchors {
			left: acInBox.right; leftMargin: -10; top: multi.verticalCenter;
			right: multi.left; rightMargin: -10; bottom: multi.verticalCenter
		}
	}

	OverviewConnection {
		id: multiToAcLoads
		ballCount: 2
		path: straight
        active: root.active && hasAcOutSystem
		value: flow(sys.acLoad.power)

		anchors {
			left: multi.right; leftMargin: -10;
			top: multi.verticalCenter
			right: acLoadBox.left; rightMargin: -10
			bottom: multi.verticalCenter
		}
	}

	OverviewConnection {
		id: pvInverterToMulti

		property int hasDcAndAcFlow: Utils.sign(noNoise(sys.pvOnAcOut.power) + noNoise(sys.pvOnAcIn1.power) + noNoise(sys.pvOnAcIn2.power))

		ballCount: 4
		path: corner
		active: root.active && hasAcSolar
		value: hasDcAndAcSolar ? hasDcAndAcFlow : flow(sys.pvOnAcOut.power)

		anchors {
			left: pvInverter.left; leftMargin: 8
			top: pvInverter.verticalCenter; topMargin: hasDcAndAcSolar ? 1 : 0
			right: multi.horizontalCenter; rightMargin: -20
			bottom: multi.bottom; bottomMargin: 10
		}
	}

	// invisible anchor point to connect the chargers to the battery
	Item {
		id: dcConnect
		anchors {
			left: multi.horizontalCenter; leftMargin: hasAcSolar ? -20  : 0
			bottom: dcSystemBox.top; bottomMargin: 10
		}
	}

	OverviewConnection {
		id: multiToDcConnect
		ballCount: 3
		path: straight
		active: root.active
		value: -flow(sys.vebusDc.power);
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: dcConnect.left
			bottom: multi.bottom; bottomMargin: 10
		}
	}

	OverviewConnection {
		id: blueSolarChargerDcConnect
		ballCount: 3
		path: straight
		active: root.active && hasDcSolar
		value: -flow(sys.pvCharger.power)
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: blueSolarCharger.left; rightMargin: -8
			bottom: dcConnect.top;
		}
	}

	OverviewConnection {
		id: chargersToBattery
		ballCount: 3
		path: straight
		active: root.active
		value: Utils.sign(noNoise(sys.pvCharger.power) + noNoise(sys.vebusDc.power))
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: battery.right; rightMargin: 10
			bottom: dcConnect.top
		}
	}

	OverviewConnection {
		id: batteryToDcSystem
		ballCount: 2
		path: straight
        active: root.active && hasDcSystem
		value: flow(sys.dcSystem.power)

		anchors {
			left: battery.right; leftMargin: -10
			top: dcSystemBox.verticalCenter;
			right: dcSystemBox.left; rightMargin: -10
			bottom: dcSystemBox.verticalCenter
		}
	}
////// moved order so it covers connections
////// moved to under Multi
    OverviewEssReason {
        anchors {
            top: multi.bottom; topMargin: 7
            horizontalCenter: parent.horizontalCenter
        }
    }

////// ADDED to show tanks & temps
    // Synchronise tank name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: root.active && root.compact
    }
    ListView
    {
        id: tanksColum

        visible: showTanks
        width: compact ? root.width : root.width * tankCount / tankTempCount
        property int tileWidth: width / Math.min (count, 4.2)
        height: root.tanksHeight
        anchors
        {
            bottom: root.bottom
            left: root.left
        }

        // flickable list if more than will fit across bottom of screen
        interactive: count > 4 ? true : false
        orientation: ListView.Horizontal

        model: TankModel { id: tankModel }
        delegate: TileTankEnhanced {
            // Without an intermediate assignment this will trigger a binding loop warning.
            property variant theService: DBusServices.get(buddy.id)
            service: theService
            width: tanksColum.tileWidth
            height: root.tanksHeight
            pumpBindPrefix: root.pumpBindPreffix
            compact: root.compact
            Connections {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile {
            title: qsTr("TANKS")
            anchors.fill: parent
            values: TileText {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }

    ListView
    {
        id: tempsColumn

        visible: showTemps
        width: compact ? root.width : root.width * tempCount / tankTempCount
        property int tileWidth: width / Math.min (count, 5.2)
        height: root.tanksHeight
        anchors
        {
            bottom: root.bottom
            bottomMargin: compact ? root.tanksHeight : 0
            right: root.right
        }

        // make list flickable if more tiles than will fit completely
        interactive: count > 4 ? true : false
        orientation: ListView.Horizontal

        model: tempsModel
        delegate: TileTemp
        {
            width: tempsColumn.tileWidth
            height: tempsColumn.height
            compact: root.compact
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile
        {
            title: qsTr("TEMPS")
            anchors.fill: parent
            values: TileText
            {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }
    ListModel { id: tempsModel }

    // When new service is found add resources as appropriate
    Connections
    {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }

    function addService(service)
    {
         switch (service.type)
        {
//////// add for temp sensors
        case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
            numberOfTemps++
            tempsModel.append({serviceName: service.name})
            break;;
        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
//////// add for VE.Direct inverters
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && inverterService == "")
                inverterService = service.name;
            break;;

//////// add for PV CHARGER voltage and current display
        case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
            numberOfPvChargers++
            if (numberOfPvChargers === 1)
                pvChargerPrefix1 = service.name;
            else if (numberOfPvChargers === 2)
                pvChargerPrefix2 = service.name;
            else if (numberOfPvChargers === 3)
                pvChargerPrefix3 = service.name;
            break;;

//////// add for PV INVERTER power display
        case DBusService.DBUS_SERVICE_PV_INVERTER:
            numberOfPvInverters++
            if (numberOfPvInverters === 1)
                pvInverterPrefix1 = service.name;
            else if (numberOfPvInverters === 2)
                pvInverterPrefix2 = service.name;
            else if (numberOfPvInverters === 3)
                pvInverterPrefix3 = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfTemps = 0
        numberOfPvChargers = 0
        numberOfPvInverters = 0
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        pvChargerPrefix1 = ""
        pvChargerPrefix2 = ""
        pvChargerPrefix3 = ""
        pvInverterPrefix1 = ""
        pvInverterPrefix2 = ""
        pvInverterPrefix3 = ""
        tempsModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }

// Details targets
    MouseArea
    {
        id: multiTarget
        anchors.centerIn: multi
        enabled: parent.active && hasInverter
        height: touchArea * 1.5; width: touchArea * 1.5
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailInverter.qml", {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasInverter
        }
    }
    MouseArea
    {
        id: acInputTarget
        anchors.centerIn: acInBox
        enabled: parent.active && hasAcInput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailAcInput.qml",
                        {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasAcInput
        }
    }
    MouseArea
    {
        id: acLoadsOnOutputTarget
        anchors.centerIn: acLoadBox
        enabled: parent.active && hasAcOutSystem
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnOutput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasAcOutSystem
        }
    }
    MouseArea
    {
        id: pvInverterTarget
        anchors.centerIn: pvInverter
        enabled: parent.active && hasAcSolar
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvInverter.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasAcSolar
        }
    }
   MouseArea
    {
        id: pvChargerTarget
        anchors.centerIn: blueSolarCharger
        enabled: parent.active && hasDcSolar
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvCharger.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasDcSolar
        }
    }
    MouseArea
    {
        id: batteryTarget
        anchors.centerIn: battery
        enabled: parent.active
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailBattery.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets
        }
    }
////// display detail targets and help message when first displayed.
    Timer {
        id: helpTimer
        running: false
        repeat: false
        interval: 5000
        triggeredOnStart: true
    }

    // help message shown when menu is first drawn
    Rectangle
    {
        id: helpBox
        color: "white"
        width: multi.width
        height: 32
        opacity: 0.7
        anchors
        {
            top: multi.bottom; topMargin: 1
            horizontalCenter: root.horizontalCenter
        }
        visible: showTargets
    }
    TileText
    {
        text: qsTr ( "Tap tile center for detail at any time" )
        color: "black"
        anchors.fill: helpBox
        wrapMode: Text.WordWrap
        font.pixelSize: 12
        show: showTargets
    }
}
