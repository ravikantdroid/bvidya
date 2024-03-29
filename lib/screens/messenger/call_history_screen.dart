import 'dart:convert';

import 'package:evidya/constants/string_constant.dart';
import 'package:evidya/model/recentchatconnectionslist_modal.dart';
import 'package:evidya/resources/app_colors.dart';
import 'package:evidya/screens/user/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../localdb/databasehelper.dart';
import '../../model/login/autogenerated.dart';
import '../../sharedpref/preference_connector.dart';
import '../../widget/gradient_bg_view.dart';
import '../livestreaming/broadcast/logs.dart';
import 'calls/audiocallscreen.dart';
import 'calls/videocallscreen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key key}) : super(key: key);

  @override
  _CallHistoryScreenState createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final dbHelper = DatabaseHelper.instance;
  CallLogController logController = CallLogController();
  // final List<CallModel> _callList = [];
  // var day;

  // bool _hasBuildCalled = false;

  @override
  void initState() {
    _query();
    super.initState();
  }

  Future<void> _query() async {
    logController.clear();
    final allRows = await dbHelper.callListRows();
    for (var row in allRows) {
      {
        if (row != null) {
          final model = CallModel(
            row[DatabaseHelper.Id],
            row[DatabaseHelper.calleeName],
            row[DatabaseHelper.calltype],
            row[DatabaseHelper.Calldrm],
            row[DatabaseHelper.Callid],
            row[DatabaseHelper.timestamp],
          );
          // _callList.add(model);
          print('model:${model.callId} ${model.name}');
          logController.addLog(model);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientColorBgView(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.appNewDarkThemeColor,
        centerTitle: true,
        title: const Text("Call History"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 2.h, left: 1.h, right: 1.h),
          child: Container(
            height: 100.h,
            padding: EdgeInsets.only(top: 2.h, left: 2.h, right: 2.h),
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/grey_background.jpg",
                  ),
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: ValueListenableBuilder(
                valueListenable: logController,
                builder: (context, log, widget) {
                  if (log.length == 0) {
                    return Center(
                      child: Text(
                        "No Recent Call History!",
                        style: TextStyle(color: Colors.grey, fontSize: 20.sp),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: log.length,
                        itemBuilder: (context, index) {
                          // dynamic parts = log[index].split('#@####@#');
                          CallModel model = log[index];
                          int day = DateTime.now()
                              .difference(DateTime(
                                  DateTime.parse(model.time).year,
                                  DateTime.parse(model.time).month,
                                  DateTime.parse(model.time).day))
                              .inDays;
                          debugPrint("Data $day");
                          return InkWell(
                            onTap: () {
                              _navigate(model);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.appNewDarkThemeColor,
                                    radius: 20,
                                    child: Text(
                                        model.name.toString().substring(0, 1),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp)),
                                  ),
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(model.name,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              children: [
                                                model.drmType ==
                                                        CallType.dialed.name
                                                    ? const Icon(
                                                        Icons
                                                            .call_made_outlined,
                                                        size: 15,
                                                        color: Colors.green,
                                                      )
                                                    : model.drmType ==
                                                            CallType
                                                                .received.name
                                                        ? const Icon(
                                                            Icons
                                                                .call_received_sharp,
                                                            size: 15,
                                                            color: Colors.green,
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .call_received_sharp,
                                                            size: 15,
                                                            color: Colors.red,
                                                          ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    day == 0
                                                        ? 'Today'
                                                        : day == 1
                                                            ? 'Yesterday'
                                                            : DateFormat(
                                                                    'EEE, MMM d')
                                                                .format(DateTime
                                                                    .parse(model
                                                                        .time
                                                                        .toString()))
                                                                .toString(),
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        color: Colors.grey)),
                                                Text(
                                                    DateFormat(', hh:mm a')
                                                        .format(DateTime.parse(
                                                            model.time)),
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        color: Colors.grey)),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      model.type == "audio"
                                          ? Image.asset(
                                              "assets/icons/svg/call.png",
                                              height: 2.5.h,
                                              width: 2.5.h,
                                              color: Colors.black26,
                                            )
                                          : Image.asset(
                                              "assets/icons/svg/camera.png",
                                              height: 3.h,
                                              width: 3.h,
                                              color: Colors.black26),
                                      // getWidget(log,filterdUsers[i].badge, filterdUsers[i].peerId),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }),
          ),
        ),
      ),
    ));
  }

  void _navigate(CallModel model) async {
    print('model:${model.callId}');

    final Connections user = await dbHelper.getUserData(model.callId);
    if (user == null) return;
    final data = await PreferenceConnector.getJsonToSharedPreferencetoken(
        StringConstant.Userdata);
    LocalDataModal _loginData;
    if (data != null) {
      var profileJson = jsonDecode(data.toString());
      _loginData = LocalDataModal.fromJson(profileJson);
    } else {
      return;
    }

    if (model.type == "audio") {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AudioCallScreen(
          userCallId: user.id,
          myAuthToken: _loginData.authToken,
          userCallName: user.name,
          userprofileimage: user.profile_image,
          othersFcmToken: user.fcm_token,
          devicefcmtoken: _loginData.fcm_token,
        );
      })).then((value) => _query());
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoCallScreen(
          userCallId: user.id.toString(),
          userAuthToken: _loginData.authToken,
          userCallName: user.name,
          calleeFcmToken: user.fcm_token,
          devicefcmtoken: _loginData.fcm_token,
          userprofileimage: user.profile_image,
        );
      })).then((value) => _query());
    }
  }
}

class CallModel {
  int id;
  String name;
  String type;
  String drmType;
  String callId;
  String time;
  CallModel(
      this.id, this.name, this.type, this.drmType, this.callId, this.time);
}
