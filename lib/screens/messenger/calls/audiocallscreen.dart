import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:sizer/sizer.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localdb/databasehelper.dart';
import '../../../model/login/autogenerated.dart';
import '../../../screens/bottom_navigation/bottom_navigaction_bar.dart';
import '../../../constants/string_constant.dart';
import '../../../main.dart';
import '../../../network/repository/api_repository.dart';
import '../../../resources/app_colors.dart';
import '../../../sharedpref/preference_connector.dart';
import '../../../utils/helper.dart';

class AudioCallScreen extends StatefulWidget {
  final String channelName;
  // final String userName;
  // final String token;
  // final String rtmChannel;
  // final String rtmToken;
  // final String rtmUser;
  // final String appid;
  final String callid;
  final String userCallId;
  final String userCallName;
  final String myAuthToken;

  final String userprofileimage;
  final String othersFcmToken;
  final String devicefcmtoken;

  const AudioCallScreen({
    Key key,
    // this.appid,
    // this.rtmChannel,
    this.userprofileimage,
    // this.rtmToken,
    // this.rtmUser,
    this.channelName,
    // this.token,
    // this.userName,
    this.callid,
    this.userCallId,
    this.userCallName,
    this.myAuthToken,
    this.othersFcmToken,
    this.devicefcmtoken,
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool _hasBuildCalled = false;

  String _appId = '';
  String _callToken = '';
  String _channalName = '';
  // String _userName = '';
  // String _calleeName;
  String _rtmUser = '';
  String _connectionStatus = "Calling";
  // bool _joined = false;
  // int _remoteUid = 0;
  final AudioPlayer _player = AudioPlayer();
  RtcEngine _engine;
  LocalDataModal _userLoginData;
  // String _userpeerid;
  // dynamic _profileJson;
  final _dbHelper = DatabaseHelper.instance;
  bool _muted = false;
  bool _speaker = false;
  Timer _timer;

  bool _isDataLoading = true;

  final _stopWatchTimer = StopWatchTimer(
    onChange: (value) {
      // final displayTime = StopWatchTimer.getDisplayTime(value);
    },
  );

  @override
  void initState() {
    super.initState();
    _isDataLoading = true;
    _hasBuildCalled = false;
    if (widget.myAuthToken != null) {
      _audioply();
    }
    localData();
    if (widget.callid != null) {
      //Incoming
      _getToken(widget.callid);
    } else {
      //Outgoing
      _callAPI(widget.userCallName, widget.userCallId);
    }
  }

  Future<void> initPlatformState(s) async {
    await [Permission.microphone].request();
    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(_appId);
    final engine = await RtcEngine.createWithContext(context);
    // debugPrint("Engine $engine");
    _engine = engine;
    _engine.setEnableSpeakerphone(_speaker);
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      // debugPrint('joinChannelSuccess ${channel} ${uid}');
      // Helper.showMessage('joinChannelSuccess ${channel} ${uid}');
      if (widget.callid?.isNotEmpty == true) {
        _connectionStatus = 'Connected';
      } else {
        _connectionStatus = 'Ringing';
      }

      if (_hasBuildCalled) {
        setState(() {
          _isDataLoading = false;
          // _joined = true;
        });
      }
    }, userJoined: (int uid, int elapsed) {
      // debugPrint('userJoined ${uid}');
      _player.stop();
      // Helper.showMessage('userJoined ${uid}');
      // setState(() {
      //   connectionStatus = "Connected";
      //   // debugPrint("connection status Connected" + connectionStatus);
      // });
      _connectionStatus = "Connected";
      // if (_hasBuildCalled) {
      // setState(() {
      _isDataLoading = false;
      // _remoteUid = uid;
      // });
      // }
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      if (_hasBuildCalled) {
        setState(() {
          _isDataLoading = false;
          // _remoteUid = uid;
        });
      }
    }, userOffline: (int uid, UserOfflineReason reason) {
      // debugPrint('userOffline ${uid}');
      _engine.leaveChannel();
      _engine.destroy();
      _onCallEnd(s);
      // Helper.showMessage('userOffline ${uid}');
      // if (_hasBuildCalled) {
      //   setState(() {
      //     // _remoteUid = 0;
      //   });
      // }
      // debugPrint("Yes Here");
    }));
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine.setClientRole(ClientRole.Broadcaster);
    // Helper.showMessage('joinChannel ${callToken}${channalName}');
    debugPrint("$_callToken -  $_channalName");
    engine.joinChannel(_callToken, _channalName, null, 0);
    if (_hasBuildCalled) {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  localData() async {
    final value = await PreferenceConnector.getJsonToSharedPreferencetoken(
        StringConstant.Userdata);
    if (value != null) {
      // _profileJson = jsonDecode(value.toString());
      _userLoginData = LocalDataModal.fromJson(jsonDecode(value.toString()));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('audio_call', callOnGroing);
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      final int counter = prefs.getInt('audio_call');
      debugPrint('value:$counter');
      if (counter == callEnd && mounted && _hasBuildCalled) {
        await prefs.setInt('audio_call', callFree);
        Navigator.pop(context);
      }
    });

    Future.delayed(const Duration(seconds: 30)).then((value) async {
      if (mounted && _connectionStatus != 'Connected') {
        await prefs.setInt('audio_call', callFree);
        Navigator.pop(context);
      }
    });
  }

  void _callAPI(String name, String id) {
    ApiRepository()
        .videocallapi(name, id, widget.myAuthToken)
        .then((value) async {
      EasyLoading.dismiss();
      if (value != null) {
        if (value.status == "successfull") {
          // setState(() {
          _rtmUser = value.body.calleeName;
          _appId = value.body.appid;
          _callToken = value.body.callToken;
          _channalName = value.body.callChannel;
          if (_hasBuildCalled) {
            setState(() {
              _isDataLoading = false;
            });
          }

          print(' name' + name + " id:" + id);
          print(' value.body' + value.body.toJson().toString());
          _fcmapicall(
            msg: 'audio',
            callId: value.body.callId,
            type: 'call_channel',
            action: 'start_call',
          );
          try {
            await _callinsert(value.body.calleeName, 'audio', id);
          } catch (_) {}
          initPlatformState(context);
        } else {
          EasyLoading.showToast("Sorry, Network Issues! Please Connect Again.",
              toastPosition: EasyLoadingToastPosition.top,
              duration: const Duration(seconds: 5));
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    showOnLock(false);

    _player?.stop();
    _engine?.leaveChannel();
    _engine?.destroy();
    _timer?.cancel();
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hasBuildCalled = true;
    return PIPView(builder: (context, isFloating) {
      return Container(
        height: 100.h,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/blackbackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
            resizeToAvoidBottomInset: !isFloating,
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                  icon: const Padding(
                    child: Icon(
                      Icons.keyboard_backspace,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  onPressed: () {
                    SystemChrome.setPreferredOrientations(
                        [DeviceOrientation.portraitUp]);
                    //Navigator.pop(context);
                    PIPView.of(context).presentBelow(BottomNavbar(index: 0));
                  }),
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10.h),
                  _callername(),
                  SizedBox(height: 2.h),
                  _rtmUserText(),
                  SizedBox(height: 1.h),
                  Text(
                    _connectionStatus,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),

                  _isDataLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : StreamBuilder<int>(
                          stream: _stopWatchTimer.rawTime,
                          initialData: _stopWatchTimer.rawTime.value,
                          builder: (context, snap) {
                            final value = snap.data;
                            final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                                hours: true,
                                second: true,
                                milliSecond: false);
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _connectionStatus == "Connected"
                                      ? Text(
                                          displayTime,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Helvetica',
                                              color: Colors.grey,
                                              fontWeight: FontWeight.normal),
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            );
                          },
                        )

                  //_toolbar(),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.h),
              decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20)),
              height: 10.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                      onTap: _onToggleSpeaker,
                      child: _speaker == true
                          ? Image.asset(
                              'assets/icons/svg/volume.png',
                              height: 4.h,
                              width: 4.h,
                            )
                          : Image.asset(
                              'assets/icons/svg/volume_off.png',
                              height: 4.h,
                              width: 4.h,
                            )),
                  GestureDetector(
                    child: Image.asset(
                      "assets/icons/svg/camera.png",
                      height: 4.h,
                      width: 4.h,
                      color: AppColors.cardContainerColor,
                    ),
                    onTap: () {
                      //EasyLoading.showToast("Go to video call!");
                    },
                  ),
                  GestureDetector(
                      onTap: _onToggleMute,
                      child: _muted
                          ? Image.asset('assets/icons/svg/mic_off.png',
                              height: 4.h, width: 4.h)
                          : Image.asset(
                              'assets/icons/svg/mic.png',
                              height: 4.h,
                              width: 4.h,
                            )),
                  GestureDetector(
                    onTap: () => _onCallEnd(context),
                    child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffca2424),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(
                          'assets/icons/svg/phone_call.png',
                          height: 3.h,
                          width: 3.h,
                          color: Colors.white,
                        )),
                  ),
                  //  Text(_message),
                ],
              ),
            )),
      );
    });
  }

  void _onToggleSpeaker() {
    setState(() {
      _speaker = !_speaker;
    });
    _engine.setEnableSpeakerphone(_speaker);
  }

  void _onCallEnd(BuildContext context) {
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    // _fcmapicall('audio', widget.calleeFcmToken, '', '', 'cut');
    _fcmapicall(
      msg: 'audio',
      callId: '',
      type: 'cut',
      action: 'end_call',
    );
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _getToken(callId) async {
    PreferenceConnector.getJsonToSharedPreferencetoken(StringConstant.loginData)
        .then((value) => {
              if (value != null)
                {
                  EasyLoading.show(),
                  ApiRepository()
                      .receivevideocallapi(callId, value)
                      .then((value) {
                    EasyLoading.dismiss();
                    if (mounted) {
                      if (value != null) {
                        if (value.status == "successfull") {
                          // setState(() {
                          _appId = value.body.appid;
                          _callToken = value.body.callToken;
                          _channalName = value.body.callChannel;
                          // _calleeName = value.body.calleeName;
                          _rtmUser = value.body.callerName;
                          // });
                          if (_hasBuildCalled) {
                            setState(() {});
                          }
                          initPlatformState(context);
                        }
                      }
                    }
                  })
                }
            });
  }

  void _fcmapicall({
    String msg,
    // String fcmtoken,
    // String image,
    String callId,
    String type,
    String action,
  }) {
    Helper.checkConnectivity().then((value) => {
          if (value)
            {
              ApiRepository()
                  .sendFCMCallTrigger(
                    callId: callId,
                    myFcmToken: widget.devicefcmtoken,
                    userProfileUrl: widget.userprofileimage,
                    body: msg,
                    type: type,
                    action: action,
                    otherUserFcmToken: widget.othersFcmToken,
                    title: _userLoginData.name,
                    fromId: _userLoginData.id.toString(),
                  )
                  .then((value) async {}),

              // ApiRepository()
              //     .sendFCMPush(
              //         message: msg,
              //         name: _userLoginData.name,
              //         token: fcmtoken,
              //         image: image,
              //         callId: callId,
              //         type: type,
              //         fcmtoken: widget.devicefcmtoken,
              //         userprofile: widget.userprofileimage,
              //         datetime: "",
              //         userpeerid: "userpeerid",
              //         senderpeerid: "senderpeerid",
              //         textid: "")
              //     .then((value) async {})
            }
          else
            {Helper.showNoConnectivityDialog(context)}
        });
  }

  Future<void> _callinsert(
      String calleeName, String calltype, String callId) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.Id: null,
      DatabaseHelper.calleeName: calleeName,
      DatabaseHelper.timestamp: DateTime.now().toString(),
      DatabaseHelper.calltype: calltype,
      DatabaseHelper.Calldrm: CallType.dialed.name,
      DatabaseHelper.Callid: callId,
    };
    final id = await _dbHelper.callinsert(row);
    debugPrint('inserted row id: $id');
    return id;
  }

  Widget _callername() {
    var name = '#';
    if (_rtmUser != "") {
      name = _rtmUser[0];
    } else if (widget.userCallName != null) {
      name = widget.userCallName[0];
    }
    return Align(
      alignment: Alignment.center,
      child: CircleAvatar(
          backgroundColor: Colors.red,
          radius: 62.0,
          child: Align(
              alignment: Alignment.center,
              child: Text(name,
                  style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
    );
    // if (_rtmUser != "") {
    //   return Align(
    //     alignment: Alignment.center,
    //     child: CircleAvatar(
    //         backgroundColor: Colors.red,
    //         radius: 62.0,
    //         child: Align(
    //             alignment: Alignment.center,
    //             child: Text(_rtmUser[0],
    //                 style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
    //   );
    // } else if (widget.userCallName != null) {
    //   return Align(
    //     alignment: Alignment.center,
    //     child: CircleAvatar(
    //         backgroundColor: Colors.red,
    //         radius: 62.0,
    //         child: Align(
    //             alignment: Alignment.center,
    //             child: Text(widget.userCallName[0],
    //                 style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
    //   );
    // } else {
    //   return Align(
    //     alignment: Alignment.center,
    //     child: CircleAvatar(
    //         backgroundColor: Colors.red,
    //         radius: 62.0,
    //         child: Align(
    //             alignment: Alignment.center,
    //             child: Text("",
    //                 style: TextStyle(color: Colors.white, fontSize: 60.sp)))),
    //   );
    // }
  }

  Widget _rtmUserText() {
    var name = '';
    if (widget.userCallName != null) {
      name = widget.userCallName;
    } else if (_rtmUser != "") {
      name = _rtmUser;
    }
    return Text(
      name,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );

    // if (widget.userCallName != null) {
    //   return Text(
    //     widget.userCallName,
    //     style: TextStyle(
    //         fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
    //   );
    // } else if (_rtmUser != "") {
    //   return Text(
    //     _rtmUser,
    //     style: TextStyle(
    //         fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
    //   );
    // } else {
    //   return Text(
    //     "",
    //     style: TextStyle(
    //         fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.white),
    //   );
    // }
  }

  Duration duration, position;
  void _audioply() async {
    String audioasset = "assets/audio/Basic.mp3";
    ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    Uint8List soundbytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    // int result = await player.earpieceOrSpeakersToggle();
    int result = await _player.playBytes(soundbytes);

    // ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
    // Uint8List soundbytes =
    //     bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    // //   player.earpieceOrSpeakersToggle();
    // int result = await _player.playBytes(soundbytes);
    // _player.onAudioPositionChanged
    //     .listen((Duration p) => {print(p), duration = p});
    // _player.onAudioPositionChanged
    //     .listen((Duration p) => {print(p), position = p});
    // _player.onPlayerCompletion.listen((event) {
    //   if (position == duration) {
    //     _player.play(audioasset);
    //   }
    // });

    //player.setVolume(0.5);

    if (result == 1) {
      //play success
      debugPrint("Sound playing successful.");
    } else {
      debugPrint("Error while playing sound.");
    }
  }
}