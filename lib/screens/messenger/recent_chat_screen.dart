import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evidya/constants/string_constant.dart';
import 'package:evidya/localdb/databasehelper.dart';
import 'package:evidya/main.dart';
import 'package:evidya/model/login/PrefranceData.dart';
import 'package:evidya/model/recentchatconnectionslist_modal.dart';
import 'package:evidya/network/repository/api_repository.dart';
import 'package:evidya/resources/app_colors.dart';
import 'package:evidya/screens/messenger/blockuserlist.dart';
import 'package:evidya/screens/messenger/call_history_screen.dart';
import 'package:evidya/screens/messenger/contactsearch_screen.dart';
import 'package:evidya/screens/messenger/group/group_list_page.dart';
// import 'package:evidya/screens/messenger/logs.dart';
import 'package:evidya/sharedpref/preference_connector.dart';
import 'package:evidya/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'chat_screen.dart';

class RecentChat extends StatefulWidget {
  final AgoraRtmClient client;
  final String userpeerid;
  final String clientpeerid;
  const RecentChat({
    Key key,
    this.client,
    this.userpeerid,
    this.clientpeerid,
  }) : super(key: key);

  @override
  _RecentChatState createState() => _RecentChatState();
}

class _RecentChatState extends State<RecentChat> {
  final List<Connections> filterdUsers = [];
  // final dbHelper = DatabaseHelper.instance;

  Timer timer;
  var no = 1;
  bool _loaded = false;
  bool _control = false;
  String _fullName;
  String _image;
  var badgevisiabilty = false;
  bool _hasBuildCalled = false;

  @override
  void initState() {
    super.initState();
    _sharedPreferencedata();
    _query();
    // _navigatequery();
    _fetchrecentchatlist();
  }

  void _sharedPreferencedata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _image = prefs.getString('profileImage');
    badgevisiabilty = prefs.getBool('groupbadge') ==
        true; //? badgevisiabilty==true:badgevisiabilty==false;

    final value = await PreferenceConnector.getJsonToSharedPreferencetoken(
        StringConstant.Userdata);
    if (value != null) {
      userdata = jsonDecode(value.toString());
      localdata = PrefranceData.fromJson(userdata);
      _fullName = localdata.name;
    }
    if (_hasBuildCalled) {
      setState(() {});
    }
  }

  // void _navigatequery() async {
  //   if (widget.clientpeerid == null) {
  //     return;
  //   }
  //   final _allRows = await dbHelper.getAlldata();
  //   final items =
  //       _allRows.where((element) => element.peerId == widget.clientpeerid);

  //   if (items.isNotEmpty) {
  //     final item = items.first;
  //     Future.delayed(Duration.zero, () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => Chat_Screen(
  //             client: widget.client,
  //             rtmpeerid: widget.clientpeerid,
  //             // messagePeerId: widget.messageLog,
  //             // logController: widget.logController,
  //             recentchatuserdetails: item,
  //             status: item.status,
  //             userlist: filterdUsers,
  //           ),
  //         ),
  //       );
  //     });
  //   } else {
  //     Future.delayed(Duration.zero, () {
  //       Navigator.of(context)
  //           .push(
  //             MaterialPageRoute(
  //               builder: (context) => GroupListPage(
  //                   client: widget.client,
  //                   // messagePeerId: widget.messageLog,
  //                   // logController: widget.groupLogController,
  //                   // groupmessagelog: widget.groupmessageLog,
  //                   groupname: widget.clientpeerid),
  //             ),
  //           )
  //           .whenComplete(initState);
  //     });
  //   }
  // }

  void _query() async {
    final dbHelper = DatabaseHelper.instance;

    final _allRows = await dbHelper.getAlldata();
    filterdUsers.clear();
    // _users.clear();

    for (final value in _allRows) {
      filterdUsers.add(value);
      // _users.add((value));
    }
    debugPrint('row _query : ${filterdUsers.length}');
    if (_hasBuildCalled && mounted) {
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _hasBuildCalled = true;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10.h),
        // here the desired height
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2.h,
            vertical: 1.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: 5,
                  right: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  color: Colors.transparent,
                ),
                child:
                    //  _image != null
                    //     ? ClipRRect(
                    //         borderRadius: BorderRadius.circular(10),
                    //         child: Image.file(
                    //           _image,
                    //           height: 7.h,
                    //           width: 15.w,
                    //           fit: BoxFit.fill,
                    //         ),
                    //       )
                    //     :
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              width: 15.w,
                              height: 7.h,
                              imageUrl: StringConstant.IMAGE_URL + _image,
                              placeholder: (context, url) =>
                                  Helper.onScreenProgress(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/teacher.PNG',
                              height: 7.h,
                              width: 15.w,
                              fit: BoxFit.fill,
                            ),
                          ),
              ),
              SizedBox(
                width: 1.h,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_fullName',
                      style: TextStyle(
                          fontSize: 2.6.h,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'online',
                      style: TextStyle(fontSize: 2.1.h, color: Colors.white),
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.addedColor,
                            AppColors.addedColor,
                          ],
                        )),
                    child: Icon(
                      Icons.search,
                      color: AppColors.appNewLightThemeColor,
                      size: 3.h,
                    )),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Contactsearch_screen()));
                  // .whenComplete(initState);
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 1.h, right: 1.h),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            //bottomLeft: Radius.circular(10),
            //bottomRight: Radius.circular(18),
          ),
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage('assets/images/whitebg.png'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 2.h, right: 2.h, top: 1.h),
              //height: 18.h,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'b',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 3.h),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'chat',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 3.h),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          InkWell(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.addedColor,
                                          AppColors.addedColor,
                                        ],
                                      )),
                                  child: Image.asset(
                                    'assets/icons/svg/call.png',
                                    height: 2.h,
                                    width: 2.h,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  'Recent Calls',
                                  style: TextStyle(
                                      fontSize: 1.6.h,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CallHistoryScreen(),
                                ),
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              'Groups',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 2.h),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.people_alt_sharp,
                              size: 3.h,
                              color: Colors.black,
                            ),
                            Visibility(
                                visible: badgevisiabilty,
                                child: const Text(
                                  'New',
                                  style: TextStyle(color: Colors.yellow),
                                ))
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GroupListPage(
                                client: widget.client,
                              ),
                            ),
                          );
                          // .whenComplete(initState);
                        },
                      ),
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              'Blocked Users',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 2.h),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Blockuserlist()));
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  )
                ],
              ),
            ),
            const Divider(
              thickness: .5,
              height: 1,
              color: Colors.black26,
              indent: 15,
              endIndent: 15,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(
                  left: 2.h,
                  top: 0.h,
                  right: 2.h,
                ),
                //height: 18.h,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.transparent),
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: messageLog,
                      builder: (context, log, widget) {
                        short(log);
                        return recentchatlist();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentchatlist() {
    if (_loaded == false) {
      return Expanded(
        child: Center(
          child: Text(
            'Loading',
            style: TextStyle(color: Colors.grey, fontSize: 3.h),
          ),
        ),
      );
    } else {
      if (filterdUsers.isEmpty) {
        return Expanded(
            child: Center(
          child: Text(
            'No Recent Chat History!',
            style: TextStyle(color: Colors.grey, fontSize: 3.h),
          ),
        ));
      } else {
        return Expanded(
          child: ListView.separated(
            itemCount: filterdUsers.length,
            separatorBuilder: (_, __) =>
                const Divider(thickness: .5, height: 1, color: Colors.black26),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              final user = filterdUsers[i];
              int day = 0;
              // debugPrint('date: ${user.timeStamp}');
              if (_loaded == true) {
                day = DateTime.now()
                    .difference(DateTime(
                        DateTime.parse(
                                user.timeStamp ?? '2022-07-25 17:36:30.956695')
                            .year,
                        DateTime.parse(
                                user.timeStamp ?? '2022-07-25 17:36:30.956695')
                            .month,
                        DateTime.parse(
                                user.timeStamp ?? '2022-07-25 17:36:30.956695')
                            .day))
                    .inDays;
              }
              return Padding(
                padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
                child: InkWell(
                  onLongPress: (() => deleteuser(user)),
                  onTap: () {
                    no = 0;
                    final dbHelper = DatabaseHelper.instance;
                    dbHelper.deletebadge(user.peerId);
                    if (_control) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat_Screen(
                            client: widget.client,
                            rtmpeerid: user.peerId,
                            // messagePeerId: widget.messageLog,
                            status: user.status,
                            // logController: widget.logController,
                            recentchatuserdetails: user,
                            userlist: filterdUsers,
                          ),
                        ),
                      );
                    } else {
                      chatLogController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat_Screen(
                            client: widget.client,
                            rtmpeerid: user.peerId,
                            // messagePeerId: widget.messageLog,
                            // logController: widget.logController,
                            recentchatuserdetails: user,
                            status: user.status,
                            userlist: filterdUsers,
                          ),
                        ),
                      );
                    }
                    _control = true;
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 3.h,
                        backgroundColor: Colors.white54,
                        child: Center(
                          child: user.profile_image == ''
                              ? Text(
                                  user.name[0],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 3.h,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 25.w,
                                    height: 9.7.h,
                                    imageUrl: StringConstant.IMAGE_URL +
                                        user.profile_image,
                                    placeholder: (context, url) =>
                                        Helper.onScreenProgress(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 2.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 2.2.h,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Text('Last Message',
                                  //     style: TextStyle(
                                  //         color: Colors.grey,
                                  //         fontSize: 2.h))
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _loaded == true
                                        ? Text(
                                            day == 0
                                                ? DateFormat('hh:mm a').format(
                                                    DateTime.parse(
                                                        user.timeStamp ?? ''))
                                                : day == 1
                                                    ? 'Yesterday'
                                                    : DateFormat('yy/MM/dd')
                                                        .format(DateTime.parse(user
                                                                    .timeStamp ==
                                                                null
                                                            ? '2022-07-25 17:36:30.956695'
                                                            : user.timeStamp
                                                                .toString()))
                                                        .toString(),
                                            style: TextStyle(
                                                fontSize: 1.6.h,
                                                color: (user.badge != null &&
                                                        user.badge != '0' &&
                                                        user.badge != '')
                                                    ? AppColors.addedColor
                                                    : Colors.grey))
                                        : const Text(''),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                if (user.badge != null &&
                                    user.badge != '0' &&
                                    user.badge != '')
                                  CircleAvatar(
                                    backgroundColor: AppColors.addedColor,
                                    radius: 1.3.h,
                                    child: Text(
                                      '${user.badge}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 1.6.h, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  var token = "";

  void _reloadChatHistory() {
    ApiRepository().recentconnection(token).then(
      (value) async {
        // if (mounted) {
        if (value != null) {
          debugPrint('value.status:${value.status}');
          if (value.status == 'successfull') {
            final users = value.body.connections;
            // apiusers = users;

            for (int a = 0; a < users.length; a++) {
              await _insert(users[a]);
            }
          }
          _query();
          _loaded = true;
          if (_hasBuildCalled) {
            setState(() {});
          }
        } else {
          Helper.showMessage('No Result found');
        }
      },
    );
  }

  void _fetchrecentchatlist() async {
    _loaded = false;
    if (_hasBuildCalled) {
      setState(() {});
    }
    final value = await PreferenceConnector.getJsonToSharedPreferencetoken(
        StringConstant.loginData);
    if (value != null) {
      token = value;
      _reloadChatHistory();
    }
  }

  _insert(Connections user) async {
    final dbHelper = DatabaseHelper.instance;

    // final transitAllowed =
    //     await dbHelper.updatedstatus(user.peerId, user.transit_allowed);
    // if (transitAllowed != user.transit_allowed) {
    //   final id = await dbHelper.update_transit_allowed(
    //       user.peerId, user.transit_allowed);
    //   debugPrint('inserted row id1: $id');
    //   // _query();
    // }

    // final blockstatus = await dbHelper.updatedstatus(user.peerId, user.status);
    // if (blockstatus.toString() != user.status) {
    //   final id = await dbHelper.updatestatus(user.peerId, user.status);
    //   debugPrint('inserted row id1: $id');
    //   // _query();
    // }
    // final fcmcount = await dbHelper.updatedfcm(user.peerId, user.fcm_token);
    // if (fcmcount == 0) {
    //   final id = await dbHelper.updatefcm(user.peerId, user.fcm_token);
    //   debugPrint('inserted row id1: $id');
    //   // _query();
    // }
    final count = await dbHelper.getcount(user.peerId);
    if (count == 0) {
      // row to insert
      Map<String, dynamic> row = {
        DatabaseHelper.Id: null,
        DatabaseHelper.name: user.name,
        DatabaseHelper.timestamp: DateTime.now().toString(),
        DatabaseHelper.userid: user.id,
        DatabaseHelper.status: user.fcm_token ?? '0',
        DatabaseHelper.peerid: user.peerId,
        DatabaseHelper.badge: '',
        DatabaseHelper.profile_image: user.profile_image,
        DatabaseHelper.email: user.email,
        DatabaseHelper.phone: user.phone,
        DatabaseHelper.blockstatus: user.status,
        DatabaseHelper.transitallowed: user.transit_allowed
      };
      try {
        final id = await dbHelper.recentchatlist(row);
        debugPrint('inserted row id1: $id');
      } catch (e) {}
    } else {
      Map<String, dynamic> row = {
        DatabaseHelper.name: user.name,
        DatabaseHelper.status: user.fcm_token ?? '0',
        DatabaseHelper.profile_image: user.profile_image,
        DatabaseHelper.phone: user.phone,
        DatabaseHelper.blockstatus: user.status,
        DatabaseHelper.transitallowed: user.transit_allowed
      };

      debugPrint('already exist row id: $count');
      try {
        int update = await dbHelper.updateRecentChatList(row, user.peerId);
        debugPrint('updated count: $update');
      } catch (e) {}
    }
    //
    // _query();
    return count;
  }

  @override
  void dispose() {
    _hasBuildCalled = false;
    timer?.cancel();
    super.dispose();
  }

  // Widget getWidget(dynamic log, badge, peerid) {
  //   CircleAvatar(
  //       backgroundColor: Colors.red,
  //       radius: 8,
  //       child: Text(badge,
  //           style: const TextStyle(fontSize: 10, color: Colors.white)));
  // }

  void deletelog(peerid) {
    messageLog.removeLog(int.parse(peerid));
  }

  var a = 0;

  void short(dynamic log) async {
    if (a < log.length) {
      updatelocaldata(log.last);
      debugPrint('updatebadge');
      _query();
      a++;
    }
  }

  void updatelocaldata(user) async {
    final dbHelper = DatabaseHelper.instance;
    dynamic peer_time = user.split('#@#&');
    await dbHelper.update(peer_time[0], peer_time[1] ?? DateTime.now());
    debugPrint('query all rows:');
    // allRows.forEach(print);
  }

  void deleteuser(Connections seleteduser) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, refresh) {
            return AlertDialog(
              title: const Text("Delete Connection"),
              content: Text("Do you want to delete a ${seleteduser.name}"),
              actions: [
                TextButton(
                  // textColor: Colors.black,
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  // function used to perform after pressing the button
                  child: const Text('NO'),
                ),
                TextButton(
                  // textColor: Colors.black,
                  onPressed: () {
                    EasyLoading.show();
                    Navigator.pop(context, true);
                    ApiRepository()
                        .deleteConnection(token, seleteduser.id)
                        .then((value) async {
                      if (value.status == 'successfull') {
                        final dbHelper = DatabaseHelper.instance;
                        await dbHelper.deleteConnection(seleteduser.id);
                        _reloadChatHistory();
                      }
                      EasyLoading.dismiss();
                    });
                  },
                  child: const Text('YES'),
                ),
              ],
            );
          });
        });
  }
}
