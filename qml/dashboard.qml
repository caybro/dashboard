/***************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import QtQuick.Controls.Material 2.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1024
    height: 600
    minimumWidth: gaugeRow.width + gaugeRow.spacing + controlsPane.contentWidth
    minimumHeight: controlsPane.contentHeight

    color: "#161616"
    title: "Dashboard Demo"

    Material.theme: Material.Dark
    Material.accent: valueSource.needleColor

    Settings {
        category: "MainWindow"
        property alias x: mainWindow.x
        property alias y: mainWindow.y
        property alias width: mainWindow.width
        property alias height: mainWindow.height
    }

    ValueSource {
        id: valueSource
    }

    // Dashboards are typically in a landscape orientation, so we need to ensure
    // our height is never greater than our width.
    Item {
        id: container
        width: parent.width - controls.width
        height: Math.min(width, parent.height)

        Row {
            id: gaugeRow
            spacing: container.width * 0.02
            anchors.centerIn: parent

            // left blinker
            TurnIndicator {
                id: leftIndicator
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: container.height * 0.1 - gaugeRow.spacing

                direction: Qt.LeftArrow
                on: valueSource.turnSignal == Qt.LeftArrow
            }

            Item {
                width: height
                height: container.height * 0.25 - gaugeRow.spacing
                anchors.verticalCenter: parent.verticalCenter

                // fuel
                CircularGauge {
                    id: fuelGauge
                    value: valueSource.fuel
                    maximumValue: 1
                    y: parent.height / 2 - height / 2 - container.height * 0.01
                    width: parent.width
                    height: parent.height * 0.7

                    style: IconGaugeStyle {
                        id: fuelGaugeStyle

                        icon: "qrc:/images/fuel-icon.png"
                        minWarningColor: Qt.rgba(0.5, 0, 0, 1)
                        needleColor: valueSource.needleColor

                        tickmarkLabel: Text {
                            color: "white"
                            font.pixelSize: fuelGaugeStyle.toPixels(0.225)
                            text: styleData.value === 0 ? "E" : (styleData.value === 1 ? "F" : "")
                        }
                        labelStepSize: 1
                    }
                }

                // oil temperature
                CircularGauge {
                    value: valueSource.temperature
                    maximumValue: 1
                    width: parent.width
                    height: parent.height * 0.7
                    y: parent.height / 2 + container.height * 0.01

                    style: IconGaugeStyle {
                        id: tempGaugeStyle

                        icon: "qrc:/images/temperature-icon.png"
                        maxWarningColor: Qt.rgba(0.5, 0, 0, 1)
                        needleColor: valueSource.needleColor

                        tickmarkLabel: Text {
                            color: "white"
                            font.pixelSize: tempGaugeStyle.toPixels(0.225)
                            text: styleData.value === 0 ? "C" : (styleData.value === 1 ? "H" : "")
                        }
                        labelStepSize: 1
                    }
                }
            }

            // speed
            CircularGauge {
                id: speedometer
                value: valueSource.kph
                anchors.verticalCenter: parent.verticalCenter
                maximumValue: 260
                // We set the width to the height, because the height will always be
                // the more limited factor. Also, all circular controls letterbox
                // their contents to ensure that they remain circular. However, we
                // don't want to extra space on the left and right of our gauges,
                // because they're laid out horizontally, and that would create
                // large horizontal gaps between gauges on wide screens.
                width: height
                height: container.height * 0.5

                style: DashboardGaugeStyle {
                    gear: valueSource.gear
                    needleColor: valueSource.needleColor
                }
            }

            // RPM tachometer
            CircularGauge {
                id: tachometer
                width: height
                height: container.height * 0.25 - gaugeRow.spacing
                value: valueSource.rpm
                maximumValue: 8
                anchors.verticalCenter: parent.verticalCenter

                style: TachometerStyle { needleColor: valueSource.needleColor }
            }

            // right blinker
            TurnIndicator {
                id: rightIndicator
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: container.height * 0.1 - gaugeRow.spacing

                direction: Qt.RightArrow
                on: valueSource.turnSignal == Qt.RightArrow
            }
        }
    }

    Pane {
        id: controlsPane
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        ColumnLayout {
            id: controls
            anchors.fill: parent

            RowLayout {
                Label { Layout.fillWidth: true; text: qsTr("Demo mode") }
                Switch { id: demoSwitch; onCheckedChanged: checked ? valueSource.startDemo() : valueSource.stopDemo() }
            }

            GroupBox {
                title: qsTr("Speedometer")
                enabled: !demoSwitch.checked
                Layout.fillWidth: true

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: 5
                    Label { Layout.fillWidth: true; text: qsTr("Speed:") }
                    SpinBox {
                        from: speedometer.minimumValue
                        to: speedometer.maximumValue
                        stepSize: 5
                        onValueChanged: valueSource.kph = value
                        Component.onCompleted: value = valueSource.kph
                    }
                    Label { Layout.fillWidth: true; text: qsTr("Max speed:") }
                    SpinBox {
                        from: speedometer.minimumValue
                        to: 360
                        stepSize: 20
                        onValueChanged: speedometer.maximumValue = value
                        Component.onCompleted: value = speedometer.maximumValue
                    }
                    Label { text: qsTr("Needle color:") }
                    ColorButton { color: valueSource.needleColor; onAccepted: valueSource.needleColor = color }
                }
            }

            GroupBox {
                title: qsTr("Tachometer")
                enabled: !demoSwitch.checked
                Layout.fillWidth: true

                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    columnSpacing: 5
                    Label { Layout.fillWidth: true; text: qsTr("RPM:") }
                    SpinBox {
                        from: tachometer.minimumValue * 1000
                        to: tachometer.maximumValue * 1000
                        stepSize: 100
                        onValueChanged: valueSource.rpm = value / 1000
                        Component.onCompleted: value = valueSource.rpm * 1000
                    }
                    Label { Layout.fillWidth: true; text: qsTr("Max RPM:") }
                    SpinBox {
                        from: 8000
                        to: 10000
                        stepSize: 1000
                        value: tachometer.maximumValue * 1000
                        onValueChanged: tachometer.maximumValue = value / 1000
                    }
                }
            }

            RowLayout {
                enabled: !demoSwitch.checked

                Label { Layout.fillWidth: true; text: qsTr("Fuel level:") }
                DoubleSpinBox {
                    from: 0
                    to: 100
                    decimals: 1
                    stepSize: 10
                    onRealValueChanged: valueSource.fuel = realValue
                    Component.onCompleted: value = valueSource.fuel * 100
                }
            }

            RowLayout {
                enabled: !demoSwitch.checked

                Label { Layout.fillWidth: true; text: qsTr("Oil temp.:") }
                DoubleSpinBox {
                    from: 0
                    to: 100
                    decimals: 1
                    stepSize: 10
                    onRealValueChanged: valueSource.temperature = realValue
                    Component.onCompleted: value = valueSource.temperature * 100
                }
            }

            GroupBox {
                title: qsTr("Blinkers")
                enabled: !demoSwitch.checked
                Layout.fillWidth: true

                Column {
                    spacing: 5

                    CheckBox { id: leftBlinker; text: qsTr("Left");
                        onClicked: {
                            if (checked) {
                                rightBlinker.checked = false;
                                valueSource.turnSignal = Qt.LeftArrow;
                            } else {
                                valueSource.turnSignal = Qt.NoArrow;
                            }
                        }
                    }
                    CheckBox { id: rightBlinker; text: qsTr("Right");
                        onClicked: {
                            if (checked) {
                                leftBlinker.checked = false;
                                valueSource.turnSignal = Qt.RightArrow;
                            } else {
                                valueSource.turnSignal = Qt.NoArrow;
                            }
                        }
                    }
                }
            }
        }
    }
}
