import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:evidya/screens/messenger/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class OnlineStatusView extends StatefulWidget {
  final String rtmpeerid;
  final String status;
  final String transitAllowed;
  final AgoraRtmClient client;
  const OnlineStatusView(
      {Key key, this.status, this.rtmpeerid, this.transitAllowed, this.client})
      : super(key: key);

  @override
  State<OnlineStatusView> createState() => _OnlineStatusViewState();
}

class _OnlineStatusViewState extends State<OnlineStatusView> {
  Timer timer;

  @override
  void dispose() async {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _isUserOnline();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _isUserOnline();
    });
    super.initState();
  }

  void _isUserOnline() async {
    if (widget.rtmpeerid.isEmpty) {
      return;
    }
    try {
      Map<dynamic, dynamic> result =
          await widget.client.queryPeersOnlineStatus([widget.rtmpeerid]);
      var clientstatus = result.values.toString();
      setState(() {
        Chat_Screen.onlinestatus =
            clientstatus == '(true)' ? 'Online' : 'Offline';
      });
    } catch (errorCode) {
      // debugPrint('Query error: ' + errorCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var status = '';
    if (widget.status != "inactive" ||
        widget.status == null ||
        widget.transitAllowed != "No") {
      status = Chat_Screen.onlinestatus;
    } else if (widget.transitAllowed == "No" && widget.status == "active") {
      status = "You are Blocked";
    } else {
      status = "Block";
    }
    return Text(
      status,
      style: TextStyle(fontSize: 2.0.h, color: Colors.white),
    );
  }
}
