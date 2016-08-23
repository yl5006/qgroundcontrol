import QtQuick 2.3
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
Rectangle
{
      property color  valuecolor:         "white"                          ///< true: show setup complete indicator
      property color  ciclectcolor:       "blue"
      property real   value:         0
      color:  "transparent"
      width:  80
      height: width
      Rectangle
      {
         id: outerRing
         z: 0
         anchors.fill: parent
         radius: width / 2
         color: "transparent"
       }
      Rectangle
      {
         id: innerRing
         z: 1
         anchors.fill: parent
         radius: outerRing.radius
         color: "transparent"
         border.color: ciclectcolor
         border.width: 8
         ConicalGradient
         {
            source: innerRing
            anchors.fill: parent
            gradient: Gradient
            {
               GradientStop { position: 0.00;  color: valuecolor }
               GradientStop { position: value; color: valuecolor }
               GradientStop { position: value+0.001; color: "transparent" }
               GradientStop { position: 1.00;  color: "transparent" }
            }
         }
      }
}

