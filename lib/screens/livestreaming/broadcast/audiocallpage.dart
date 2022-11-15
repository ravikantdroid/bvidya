// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:evidya/localdb/databasehelper.dart';
// import 'package:evidya/model/login/autogenerated.dart';
// import 'package:evidya/screens/bottom_navigation/bottom_navigaction_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pip_view/pip_view.dart';
// import 'package:sizer/sizer.dart';
// import 'package:stop_watch_timer/stop_watch_timer.dart';
// import '../../../constants/string_constant.dart';
// import '../../../main.dart';
// import '../../../network/repository/api_repository.dart';
// import '../../../resources/app_colors.dart';
// import '../../../sharedpref/preference_connector.dart';
// import '../../../utils/helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AudioCallpage extends StatefulWidget {
//   final String channelName;
//   final String userName;
//   final String token;
//   final String rtmChannel;
//   final String rtmToken;
//   final String rtmUser;
//   final String appid;
//   final String Callid;
//   final dynamic userCallId;
//   final String userFcmToken;
//   final String userCallName, userprofileimage;
//   final String calleeFcmToken;
//   final String devicefcmtoken;

//   const AudioCallpage(
//       {this.appid,
//       this.rtmChannel,
//       this.userprofileimage,
//       this.rtmToken,
//       this.rtmUser,
//       this.channelName,
//       this.token,
//       this.userName,
//       this.Callid,
//       this.userCallId,
//       this.userCallName,
//       this.userFcmToken,
//       this.calleeFcmToken,
//       Key key,
//       this.devicefcmtoken})
//       : super(key: key);

//   @override
//   State<AudioCallpage> createState() => _TestLiveStreamState();
// }

// class _TestLiveStreamState extends State<AudioCallpage> {
//   String APP_ID = '';

//   String Token = '',
//       channalname = '',
//       username = '',
//       calleename,
//       rtmUser = '',
//       connectionstatus = "Calling";
//   bool _joined = false;
//   int _remoteUid = 0;
//   AudioPlayer player = AudioPlayer();
//   RtcEngine _engine;
//   var Logindata, userpeerid;
//   dynamic profileJson;
//   final dbHelper = DatabaseHelper.instance;
//   bool muted = false;
//   bool volume = true;
//   Timer _timer;
//   final _stopWatchTimer = StopWatchTimer(
//     onChange: (value) {
//       final displayTime = StopWatchTimer.getDisplayTime(value);
//     },
//   );

//   @override
//   void initState() {
//     super.initState();
//     if (widget.userFcmToken != null) {
//       audioply();
//     }
//     localData();
//     if (widget.Callid != null) {
//       getToken(widget.Callid);
//     } else {
//       callAPI(widget.userCallName, widget.userCallId);
//     }
//   }

//   Future<void> initPlatformState(s) async {
//     await [Permission.camera, Permission.microphone].request();
//     // Create RTC client instance
//     RtcEngineContext context = RtcEngineContext(APP_ID);
//     var engine = await RtcEngine.createWithContext(context);
//     debugPrint("Engine $engine");
//     _engine = engine;
//     engine.setEventHandler(RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//       debugPrint('joinChannelSuccess ${channel} ${uid}');
//       Helper.showMessage('joinChannelSuccess ${channel} ${uid}');
//       setState(() {
//         _joined = true;
//       });
//     }, userJoined: (int uid, int elapsed) {
//       debugPrint('userJoined ${uid}');
//       player.stop();
//       Helper.showMessage('userJoined ${uid}');
//       setState(() {
//         connectionstatus = "Connected";
//         debugPrint("connection status Connected" + connectionstatus);
//       });

//       _stopWatchTimer.onExecute.add(StopWatchExecute.start);
//       setState(() {
//         _remoteUid = uid;
//       });
//     }, userOffline: (int uid, UserOfflineReason reason) {
//       debugPrint('userOffline ${uid}');
//       _engine.leaveChannel();
//       _engine.destroy();
//       _onCallEnd(s);
//       Helper.showMessage('userOffline ${uid}');
//       setState(() {
//         _remoteUid = 0;
//       });
//       debugPrint("Yes Here");
//     }));
//     await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await engine.setClientRole(ClientRole.Broadcaster);
//     Helper.showMessage('joinChannel ${Token}${channalname}');
//     await engine.joinChannel(Token, channalname, null, 0);
//   }

//   void localData() async {
//     PreferenceConnector.getJsonToSharedPreferencetoken(StringConstant.Userdata)
//         .then((value) => {
//               if (value != null)
//                 {
//                   profileJson = jsonDecode(value.toString()),
//                   setState(() {
//                     Logindata = LocalDataModal.fromJson(profileJson);
//                   })
//                 }
//             });

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('audiocall', 0);
//     _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.reload();
//       final int counter = prefs.getInt('audiocall');
//       debugPrint("bac:$counter");
//       if (counter == 20) {
//         Navigator.pop(context);
//       }
//     });
//   }

//   void callAPI(name, id) {
//     ApiRepository().videocallapi(name, id, widget.userFcmToken).then((value) {
//       EasyLoading.dismiss();
//       if (value != null) {
//         if (value.status == "successfull") {
//           setState(() {
//             rtmUser = value.body.calleeName;
//             APP_ID = value.body.appid;
//             Token = value.body.callToken;
//             channalname = value.body.callChannel;
//             username = Logindata.id.toString();
//           });
//           debugPrint("App Id $APP_ID, Token $Token");
//           fcmapicall('audio', widget.calleeFcmToken, '', value.body.callId,
//               'call_channel');
//           _callinsert(value.body.calleeName, 'audio', 'Dilled_Call');
//           initPlatformState(context);
//         } else {
//           EasyLoading.showToast("Sorry, Network Issues! Please Connect Again.",
//               toastPosition: EasyLoadingToastPosition.top,
//               duration: Duration(seconds: 5));
//           Navigator.pop(context);
//         }
//       }
//     });
//   }

//   @override
//   void dispose() async {
//     showOnLock(false);

//     player.stop();
//     _engine.leaveChannel();
//     _engine.destroy();
//     _timer.cancel();
//     _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

//     await _stopWatchTimer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PIPView(builder: (context, isFloating) {
//       return Container(
//         height: 100.h,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/blackbackground.jpg"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Scaffold(
//             resizeToAvoidBottomInset: !isFloating,
//             backgroundColor: Colors.transparent,
//             appBar: AppBar(
//               backgroundColor: Colors.transparent,
//               centerTitle: true,
//               leading: IconButton(
//                   icon: const Padding(
//                     child: Icon(
//                       Icons.keyboard_backspace,
//                       color: Colors.white,
//                     ),
//                     padding: EdgeInsets.all(8),
//                   ),
//                   onPressed: () {
//                     SystemChrome.setPreferredOrientations(
//                         [DeviceOrientation.portraitUp]);
//                     //Navigator.pop(context);
//                     PIPView.of(context).presentBelow(BottomNavbar(index: 0));
//                   }),
//             ),
//             body: Container(
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 children: <Widget>[
//                   SizedBox(height: 10.h),
//                   callername(),
//                   SizedBox(height: 2.h),

//                   rtmUsertext(),
//                   SizedBox(height: 1.h),
//                   Text(
//                     connectionstatus,
//                     style: TextStyle(fontSize: 13.sp, color: Colors.grey),
//                   ),

//                   StreamBuilder<int>(
//                     stream: _stopWatchTimer.rawTime,
//                     initialData: _stopWatchTimer.rawTime.value,
//                     builder: (context, snap) {
//                       final value = snap.data;
//                       final displayTime = StopWatchTimer.getDisplayTime(value,
//                           hours: true, second: true, milliSecond: false);
//                       return Column(
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(8),
//                             child: connectionstatus != "Calling"
//                                 ? Text(
//                                     displayTime,
//                                     style: const TextStyle(
//                                         fontSize: 20,
//                                         fontFamily: 'Helvetica',
//                                         color: Colors.grey,
//                                         fontWeight: FontWeight.normal),
//                                   )
//                                 : SizedBox(),
//                           ),
//                         ],
//                       );
//                     },
//                   )

//                   //_toolbar(),
//                 ],
//               ),
//             ),
//             bottomNavigationBar: Container(
//               padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
//               decoration: BoxDecoration(
//                   color: AppColors.cardColor,
//                   borderRadius: BorderRadius.circular(20)),
//               height: 10.h,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   GestureDetector(
//                       onTap: _onToggleVolume,
//                       child: volume == true
//                           ? Image.asset(
//                               'assets/icons/svg/volume.png',
//                               height: 4.h,
//                               width: 4.h,
//                             )
//                           : Image.asset(
//                               'assets/icons/svg/volume_off.png',
//                               height: 4.h,
//                               width: 4.h,
//                             )),
//                   GestureDetector(
//                     child: Image.asset(
//                       "assets/icons/svg/camera.png",
//                       height: 4.h,
//                       width: 4.h,
//                       color: AppColors.cardContainerColor,
//                     ),
//                     onTap: () {
//                       //EasyLoading.showToast("Go to video call!");
//                     },
//                   ),
//                   GestureDetector(
//                       onTap: _onToggleMute,
//                       child: muted
//                           ? Image.asset('assets/icons/svg/mic_off.png',
//                               height: 4.h, width: 4.h)
//                           : Image.asset(
//                               'assets/icons/svg/mic.png',
//                               height: 4.h,
//                               width: 4.h,
//                             )),
//                   GestureDetector(
//                     onTap: () => _onCallEnd(context),
//                     child: Container(
//                         decoration: BoxDecoration(
//                             color: Color(0xffca2424),
//                             borderRadius: BorderRadius.circular(10)),
//                         padding: const EdgeInsets.all(15.0),
//                         child: Image.asset(
//                           'assets/icons/svg/phone_call.png',
//                           height: 3.h,
//                           width: 3.h,
//                           color: Colors.white,
//                         )),
//                   ),
//                   //  Text(_message),
//                 ],
//               ),
//             )),
//       );
//     });
//   }

//   void _onToggleVolume() {
//     setState(() {
//       volume = !volume;
//     });
//     _engine.setEnableSpeakerphone(volume);
//   }

//   void _onCallEnd(BuildContext context) {
//     _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
//     fcmapicall('audio', widget.calleeFcmToken, '', '', 'cut');
//     Navigator.pop(context);
//   }

//   void _onToggleMute() {
//     setState(() {
//       muted = !muted;
//     });
//     _engine.muteLocalAudioStream(muted);
//   }

//   void getToken(callId) async {
//     PreferenceConnector.getJsonToSharedPreferencetoken(StringConstant.loginData)
//         .then((value) => {
//               if (value != null)
//                 {
//                   EasyLoading.show(),
//                   ApiRepository()
//                       .receivevideocallapi(callId, value)
//                       .then((value) {
//                     EasyLoading.dismiss();
//                     if (mounted) {
//                       if (value != null) {
//                         if (value.status == "successfull") {
//                           setState(() {
//                             APP_ID = value.body.appid;
//                             Token = value.body.callToken;
//                             channalname = value.body.callChannel;
//                             calleename = value.body.calleeName;
//                             rtmUser = value.body.callerName;
//                           });
//                           initPlatformState(context);
//                         }
//                       }
//                     }
//                   })
//                 }
//             });
//   }

//   void fcmapicall(
//     String msg,
//     String fcmtoken,
//     image,
//     call_id,
//     type,
//   ) {
//     Helper.checkConnectivity().then((value) => {
//           if (value)
//             {
//               ApiRepository()
//                   .fcmnotifiction(
//                       msg,
//                       Logindata.name,
//                       fcmtoken,
//                       image,
//                       call_id,
//                       type,
//                       widget.devicefcmtoken,
//                       widget.userprofileimage,
//                       "",
//                       "userpeerid",
//                       "senderpeerid",
//                       "")
//                   .then((value) async {})
//             }
//           else
//             {Helper.showNoConnectivityDialog(context)}
//         });
//   }

//   Future<void> _callinsert(
//       String calleeName, String calltype, String Calldrm) async {
//     // row to insert
//     Map<String, dynamic> row = {
//       DatabaseHelper.Id: null,
//       DatabaseHelper.calleeName: calleeName,
//       DatabaseHelper.timestamp: DateTime.now().toString(),
//       DatabaseHelper.calltype: calltype,
//       DatabaseHelper.Calldrm: Calldrm,
//     };
//     final id = await dbHelper.callinsert(row);
//     debugPrint('inserted row id: $id');
//     return id;
//   }

//   Widget callername() {
//     if (rtmUser != "") {
//       return Align(
//         alignment: Alignment.center,
//         child: CircleAvatar(
//             backgroundColor: Colors.red,
//             radius: 62.0,
//             child: Align(
//                 alignment: Alignment.center,
//                 child: Text(rtmUser[0],
//                     style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
//       );
//     } else if (widget.userCallName != null) {
//       return Align(
//         alignment: Alignment.center,
//         child: CircleAvatar(
//             backgroundColor: Colors.red,
//             radius: 62.0,
//             child: Align(
//                 alignment: Alignment.center,
//                 child: Text(widget.userCallName[0],
//                     style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
//       );
//     } else {
//       return Align(
//         alignment: Alignment.center,
//         child: CircleAvatar(
//             backgroundColor: Colors.red,
//             radius: 62.0,
//             child: Align(
//                 alignment: Alignment.center,
//                 child: Text("",
//                     style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
//       );
//     }
//   }

//   Widget rtmUsertext() {
//     if (widget.userCallName != null) {
//       return Text(
//         widget.userCallName,
//         style: TextStyle(
//             fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
//       );
//     } else if (rtmUser != "") {
//       return Text(
//         rtmUser,
//         style: TextStyle(
//             fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
//       );
//     } else {
//       return Text(
//         "",
//         style: TextStyle(
//             fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
//       );
//     }
//   }

//   void audioply() async {
//     String audioasset = "assets/audio/Basic.mp3";
//     var duration, position;
//     ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
//     Uint8List soundbytes =
//         bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
//     //   player.earpieceOrSpeakersToggle();
//     int result = await player.playBytes(soundbytes);
//     player.onAudioPositionChanged
//         .listen((Duration p) => {print(p), duration = p});
//     player.onAudioPositionChanged
//         .listen((Duration p) => {print(p), position = p});
//     player.onPlayerCompletion.listen((event) {
//       if (position = duration) {
//         player.play(audioasset);
//       }
//     });

//     //player.setVolume(0.5);

//     if (result == 1) {
//       //play success
//       debugPrint("Sound playing successful.");
//     } else {
//       debugPrint("Error while playing sound.");
//     }
//   }
// }