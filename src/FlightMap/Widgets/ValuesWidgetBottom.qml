/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.4
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2

import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Palette       1.0
import QGroundControl               1.0

QGCFlickable {
    id:                 _root
    height:             Math.min(maxHeight, _largeColumn.y + _largeColumn.height)
    contentHeight:      _largeColumn.y + _largeColumn.height
    flickableDirection: Flickable.VerticalFlick
    clip:               true

    property var    qgcView
    property color  textColor
    property var    maxHeight

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : QGroundControl.multiVehicleManager.disconnectedVehicle
    property real   _margins:       ScreenTools.defaultFontPixelWidth / 2

    QGCPalette { id:qgcPal; colorGroupEnabled: true }

    ValuesWidgetController {
        id: controller
    }

    function showPicker() {
        qgcView.showDialog(propertyPicker,qsTr("显示值设置")/*"Value Widget Setup"*/, qgcView.showDialogDefaultWidth, StandardButton.Ok)
    }

    function listContains(list, value) {
        for (var i=0; i<list.length; i++) {
            if (list[i] === value) {
                return true
            }
        }
        return false
    }
    function getIcon(name) {
        if(name== "altitudeRelative")
           return "/qmlimages/altitudeRelative.svg"
        if(name== "altitudeAMSL")
           return "/qmlimages/altitudeAMSL.svg"
        if(name== "climbRate")
           return "/qmlimages/climbRate.svg"
        if(name== "airSpeed")
           return "/qmlimages/airSpeed.svg"
        if(name== "groundSpeed")
           return "/qmlimages/groundSpeed.svg"
        if(name== "thrust")
           return "/qmlimages/Throttle.svg"
    }
    Column {
        id:         _largeColumn
        width:      parent.width
        spacing:    _margins*1.2

        Repeater {
            model: _activeVehicle ? controller.largeValues : 0

//           Column {
             Row {
                width:  _largeColumn.width*0.9//_largeColumn.width
                spacing:    _margins*5
                anchors.horizontalCenter:  _largeColumn.horizontalCenter
                property Fact fact: _activeVehicle.getFact(modelData.replace("Vehicle.", ""))
                property bool largeValue: _root.listContains(controller.altitudeProperties, fact.name)
                property Fact factangle : _activeVehicle.getFact("homeangle")
                QGCLabel {
                    width:                  parent.width*0.25
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize  : ScreenTools.mediumFontPointSize
                    fontSizeMode:           Text.HorizontalFit
                    color:                  Qt.rgba(0.102,0.887,0.609,1)//textColor
                    text:                   fact.shortDescription
                }

                QGCLabel {
                    width:                  fact.name == "homedis" ? parent.width*0.2:parent.width*0.3
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize  : ScreenTools.mediumFontPointSize
                    horizontalAlignment:    Text.AlignHCenter
                    fontSizeMode:           Text.HorizontalFit
                    color:                  textColor
                    text:                   fact.valueString
                }
                QGCLabel {
                    visible:                fact.name == "homedis"
                    width:                  parent.width*0.15
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize  : ScreenTools.mediumFontPointSize
                    horizontalAlignment:    Text.AlignHCenter
                    fontSizeMode:           Text.HorizontalFit
                    color:                  textColor
                    text:                   factangle.valueString
                }
                QGCLabel {
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize  : ScreenTools.mediumFontPointSize
                    fontSizeMode:           Text.HorizontalFit
                    color:                  textColor
                    text:                   fact.units ? fact.units  : ""
                }
            }
        } // Repeater - Large
    } // Column - Large

    Flow {
        id:                 _smallFlow
        width:              parent.width
        anchors.topMargin:  _margins
        anchors.top:        _largeColumn.bottom
        layoutDirection:    Qt.LeftToRight
        spacing:            _margins
        Repeater {
            model: _activeVehicle ? controller.smallValues : 0

            Column {
                id:     valueColumn
                width:  (_root.width / 2) - (_margins / 2) - 0.1
                clip:   true

                property Fact fact: _activeVehicle.getFact(modelData.replace("Vehicle.", ""))

                QGCLabel {
                    width:                  parent.width
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
                    fontSizeMode:           Text.HorizontalFit
                    color:                  textColor
                    text:                   fact.shortDescription
                }
                QGCLabel {
                    width:                  parent.width
                    horizontalAlignment:    Text.AlignHCenter
                    color:                  textColor
                    fontSizeMode:           Text.HorizontalFit
                    text:                   fact.enumOrValueString
                }
                QGCLabel {
                    width:                  parent.width
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:         ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
                    fontSizeMode:           Text.HorizontalFit
                    color:                  textColor
                    text:                   fact.units
                }
            }
        } // Repeater - Small
    } // Flow

    Component {
        id: propertyPicker

        QGCViewDialog {
            id: _propertyPickerDialog
            height: ScreenTools.defaultFontPixelHeight*20
            QGCFlickable {
                id:                 pick
                anchors.fill:       parent
                contentHeight:      _loader.y + _loader.height
                flickableDirection: Flickable.VerticalFlick
                clip:               true

                QGCLabel {
                    id:     _label
                text:   qsTr("选择需要显示的信息")//"Select the values you want to display:"
                }

                Loader {
                    id:                 _loader
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.topMargin:  _margins
                    anchors.top:        _label.bottom
                    sourceComponent:    factGroupList

                    property var factGroup:     _activeVehicle
                    property var factGroupName: "Vehicle"
                }
            }
        }
    }

    Component {
        id: factGroupList

        // You must push in the following properties from the Loader
        // property var factGroup
        // property string factGroupName

        Column {
            id:         _root
            spacing:    _margins

            QGCLabel {
                width:      parent.width
                wrapMode:   Text.WordWrap
                visible:    !factGroup     //add  yaoling
                text:       factGroup ? factGroupName : qsTr("机体需处于连接状态")//"Vehicle must be connected to assign values."
            }

            Repeater {
                model: factGroup ? factGroup.factNames : 0

                RowLayout {
                    spacing: _margins

                    property string propertyName: factGroupName + "." + modelData

                    function removeFromList(list, value) {
                        var newList = []
                        for (var i=0; i<list.length; i++) {
                            if (list[i] !== value) {
                                newList.push(list[i])
                            }
                        }
                        return newList
                    }

                    function addToList(list, value) {
                        var found = false
                        for (var i=0; i<list.length; i++) {
                            if (list[i] === value) {
                                found = true
                                break
                            }
                        }
                        if (!found) {
                            list.push(value)
                        }
                        return list
                    }

                    function updateValues() {
                        if (_addCheckBox.checked) {
//                            if (_largeCheckBox.checked) {
                                controller.largeValues = addToList(controller.largeValues, propertyName)
                                controller.smallValues = removeFromList(controller.smallValues, propertyName)
//                            } else {
//                                controller.smallValues = addToList(controller.smallValues, propertyName)
//                                controller.largeValues = removeFromList(controller.largeValues, propertyName)
//                            }
                        } else {
                            controller.largeValues = removeFromList(controller.largeValues, propertyName)
                            controller.smallValues = removeFromList(controller.smallValues, propertyName)
                        }
                    }

                    QGCCheckBox {
                        id:                     _addCheckBox
                        text:                   factGroup.getFact(modelData).shortDescription
                   //     checked:                listContains(controller.smallValues, propertyName) || _largeCheckBox.checked
                        checked:                listContains(controller.largeValues, propertyName)// || _largeCheckBox.checked
                        onClicked:              updateValues()
                        Layout.fillWidth:       true
                        Layout.minimumWidth:    ScreenTools.defaultFontPixelWidth * 20
                    }

//                    QGCCheckBox {
//                        id:                     _largeCheckBox
//                        text:                   qsTr("大")//"Large"
//                        checked:                listContains(controller.largeValues, propertyName)
//                        enabled:                _addCheckBox.checked
//                        onClicked:              updateValues()
//                    }
                }
            }

            Item { height: 1; width: 1 }

            Repeater {
                model: factGroup ? factGroup.factGroupNames : 0
                Loader {
                    sourceComponent: factGroupList
                    property var    factGroup:      _root ? _root.parent.factGroup.getFactGroup(modelData) : undefined
                    property string factGroupName:  _root ? _root.parent.factGroupName + "." + modelData : ""
                }
            }
        }
    }
}
