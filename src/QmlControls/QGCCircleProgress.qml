import QtQuick 2.3
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
Rectangle
{
      property color  valuecolor:         "white"                          ///< true: show setup complete indicator
      property color  ciclectcolor:       "blue"
      property real   value:         0
      color:  "transparent"
      width:  60
      height: width

      Rectangle
      {
         id: outerRing
         z: 0
         anchors.fill: parent
         radius: Math.max(width, height) / 2
         color: ciclectcolor//"transparent"
      }
      Rectangle
      {
         id: innerRing
         z: 1
         anchors.fill: parent
         anchors.margins: 8
         radius: outerRing.radius
         color: "transparent"
         ConicalGradient
         {
            source: innerRing
            anchors.fill: parent
            gradient: Gradient
            {
               GradientStop { position: 0.00; color: valuecolor }
               GradientStop { position: value; color: valuecolor }
               GradientStop { position: value + 0.01; color: "transparent" }
               GradientStop { position: 1.00; color: "transparent" }
            }
         }
      }



      Text
      {
         id: progressLabel
         anchors.centerIn: parent
         color: "black"
         text: (value * 100).toFixed() + "%"
      }
}

