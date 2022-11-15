import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String msg;
  final String additionalInfo;
  const ChatBubble({Key key, @required this.msg, this.additionalInfo = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  //real message
                  TextSpan(
                    text: msg + "    ",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),

                  //fake additionalInfo as placeholder
                  TextSpan(
                    text: additionalInfo,
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //real additionalInfo
          Positioned(
            child: Text(
              additionalInfo,
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            right: 8.0,
            bottom: 4.0,
          )
        ],
      ),
    );
  }
}
