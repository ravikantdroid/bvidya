import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  double minWidth;
  Widget child;
  Function onPressed;
  Color color;
  Color textColor;
  ShapeBorder shape;
  FlatButton(
      {Key key,
      this.minWidth,
      this.child,
      this.onPressed,
      this.shape,
      this.textColor,
      this.color = Colors.transparent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      // minimumSize: Size(minWidth, _height),
      minimumSize: Size.fromWidth(minWidth),
      textStyle: TextStyle(color: textColor),
      backgroundColor: color,
      padding: const EdgeInsets.all(0),
    );

    return TextButton(
      child: child,
      // style: flatButtonStyle,
      onPressed: onPressed,
    );
  }
}
