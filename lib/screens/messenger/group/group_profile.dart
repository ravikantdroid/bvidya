import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evidya/resources/app_colors.dart';
import 'package:evidya/screens/bottom_navigation/bottom_navigaction_bar.dart';
import 'package:evidya/screens/messenger/group/create_group.dart';
import 'package:evidya/screens/messenger/group/group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../constants/string_constant.dart';
import '../../../localdb/databasehelper.dart';
import '../../../main.dart';
import '../../../model/login/autogenerated.dart';
import '../../../network/repository/api_repository.dart';
import '../../../sharedpref/preference_connector.dart';
import '../../../utils/helper.dart';
// import '../../../widget/flat_button.dart';
// import '../logs.dart';
import '../../../widget/gradient_bg_view.dart';
import '../sender_profile_page.dart';

class GroupProfilePage extends StatefulWidget {
  final String senderName;
  final String peerid;
  final String senderpeerid;
  final String groupimage;
  final String groupadmin;
  final dynamic self;
  final int groupid;
  final dynamic groupmember;

  // final GroupLongController logController;

  const GroupProfilePage(
      {this.senderName,
      this.peerid,
      this.senderpeerid,
      this.groupmember,
      this.groupimage,
      this.self,
      // this.logController,
      this.groupadmin,
      this.groupid,
      Key key})
      : super(key: key);

  @override
  State<GroupProfilePage> createState() => _GroupProfilePageState();
}

class _GroupProfilePageState extends State<GroupProfilePage> {
  final dbHelper = DatabaseHelper.instance;
  dynamic profileJson;
  var Logindata, userpeerid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localdata();
  }

  localdata() {
    PreferenceConnector.getJsonToSharedPreferencetoken(StringConstant.Userdata)
        .then((value) => {
              if (value != null)
                {
                  profileJson = jsonDecode(value.toString()),
                  setState(() {
                    Logindata = LocalDataModal.fromJson(profileJson);
                  }),
                  debugPrint("WIddget ${Logindata}"),
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return GradientColorBgView(
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/images/back_ground.jpg"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_backspace,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 7.h, left: 1.h, right: 1.h),
                      padding:
                          EdgeInsets.only(left: 3.h, right: 3.h, bottom: 2.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage(
                              "assets/images/grey_background.jpg",
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 6.h,
                          ),
                          Text(
                            widget.senderName,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .5,
                                fontSize: 17.sp),
                          ),
                          Text(
                            "${widget.groupadmin} (admin)",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .5,
                                fontSize: 12.sp),
                          ),
                        ],
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      //alignment: Alignment.center,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF450d35),
                            Color(0xFF4a0d36),
                            Color(0xFF4e1141),
                            Color(0xFF520e35),
                            Color(0xFF520e35),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Container(
                              height: 10.h,
                              width: 21.w,
                              margin: const EdgeInsets.only(
                                  bottom: 5, right: 5, left: 5, top: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 1, color: Colors.transparent),
                                  color: Colors.transparent),
                              child: widget.groupimage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        width: 25.w,
                                        height: 10.h,
                                        imageUrl: StringConstant.IMAGE_URL +
                                            widget.groupimage,
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
                                    )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.only(
                    top: 1.h, right: 1.h, left: 1.h, bottom: 1.h),
                padding: EdgeInsets.only(
                    left: 2.h, right: 2.h, top: 3.h, bottom: 2.h),
                width: double.infinity,
                height: 71.h,
                decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/grey_background.jpg",
                        ),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Group Member",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            child: Container(
                                padding: EdgeInsets.all(5),
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
                                  Icons.person_add,
                                  color: AppColors.appNewLightThemeColor,
                                  size: 3.h,
                                )),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateGroup(
                                            page: "InGroup",
                                            groupId: widget.groupid,
                                          )));
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onLongPress: () {
                                  debugPrint("adas");
                                  _menu(i, StringConstant.removeuser,
                                      StringConstant.removegroupcontent);
                                },
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SenderProfilePage(
                                            senderName:
                                                widget.groupmember[i].name,
                                            peerid: widget.groupmember[i].pid,
                                            senderpeerid:
                                                widget.groupmember[i].pid,
                                            groupmemberdetails:
                                                widget.groupmember[i]),
                                      ));
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blueGrey,
                                          child: Center(
                                            child: widget.groupmember[i]
                                                        .profileImage ==
                                                    ""
                                                ? Text(
                                                    "${widget.groupmember[i].name[0]}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.sp,
                                                        fontWeight:
                                                            FontWeight.bold))
                                                : CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    width: 25.w,
                                                    height: 9.7.h,
                                                    imageUrl: StringConstant
                                                            .IMAGE_URL +
                                                        widget.groupmember[i]
                                                            .profileImage,
                                                    placeholder:
                                                        (context, url) => Helper
                                                            .onScreenProgress(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                        width: 2.w,
                                      ),
                                      Text(
                                        widget.groupmember[i].name,
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.brown,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: widget.groupmember.length),
                      SizedBox(
                        height: 1.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          createMessengerGroup(
                              widget.self.pid, widget.self.name, "exit-group");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.exit_to_app,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text("Exit Group",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          clearchat();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_sharp,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text("Clear Chat",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black))
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      GestureDetector(
                        onTap: () {
                          _menu(widget.groupid, StringConstant.exitgroup,
                              StringConstant.exitgroupcontent);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text("Delete Group",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearchat() {
    _menu(widget.senderName, StringConstant.cleargroup,
        StringConstant.cleargroupcontent);

    // EasyLoading.showToast("Clean Chat", toastPosition: EasyLoadingToastPosition.bottom);
  }

  void _menu(var i, title, content) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, refresh) {
            return AlertDialog(
              title: Text(title),
              // To display the title it is optional
              content: Text(content),
              // Message which will be pop up on the screen
              // Action widget which will provide the user to acknowledge the choice
              actions: [
                TextButton(
                  // FlatButton widget is used to make a text to work like a button
                  // textColor: Colors.black,
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  // function used to perform after pressing the button
                  child: Text('CANCEL'),
                ),
                TextButton(
                  // textColor: Colors.black,
                  onPressed: () {
                    Navigator.pop(context, true);
                    setState(() => widget.groupmember.remove(i));
                    if (title == StringConstant.removeuser) {
                      createMessengerGroup(widget.groupmember[i].pid,
                          widget.groupmember[i].name, "remove-group-member");
                    } else if (title == StringConstant.cleargroup) {
                      dbHelper.cleargroupchat(widget.senderName);
                      groupChatLogController.clear();
                    } else {
                      createMessengerGroup(
                          widget.groupid.toString(), "", "delete-group");
                    }
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
        });
  }

  void createMessengerGroup(var id, String name, endpoint) {
    Helper.checkConnectivity().then((value) => {
          if (value)
            {
              PreferenceConnector.getJsonToSharedPreference(
                      StringConstant.loginData)
                  .then((value) => {
                        if (value != null)
                          {
                            ApiRepository()
                                .deletegroupmember(
                                    token: value,
                                    groupid: widget.groupid,
                                    membername: name,
                                    groupMemberid: id,
                                    endpoint: endpoint)
                                .then((value) {
                              if (value['status'] == "successfull") {
                                cleardb(endpoint);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BottomNavbar(
                                              index: 2,
                                            )));
                                EasyLoading.dismiss();
                                debugPrint("Success $value");
                                setState(() {
                                  EasyLoading.showToast(value['message'],
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom,
                                      duration: const Duration(seconds: 2));
                                });
                              } else {
                                EasyLoading.dismiss();
                                EasyLoading.showToast(value['message'],
                                    toastPosition:
                                        EasyLoadingToastPosition.bottom,
                                    duration: const Duration(seconds: 5));
                              }
                            })
                          }
                        else
                          {
                            EasyLoading.dismiss(),
                            EasyLoading.showToast(
                                "Something went wrong please logout and login again.")
                          }
                      })
            }
          else
            {Helper.showNoConnectivityDialog(context)}
        });
  }

  void cleardb(endpoint) {
    if (endpoint == "delete-group" || endpoint == "exit-group") {
      dbHelper.cleargroupchat(widget.senderName);
    }
  }
}
