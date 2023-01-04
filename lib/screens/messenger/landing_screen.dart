import 'package:agora_rtm/agora_rtm.dart';
import 'package:evidya/resources/app_colors.dart';
import 'package:evidya/screens/messenger/group/group_chat_screen.dart';
import 'package:evidya/screens/splash/splash_screen.dart';
import 'package:evidya/widget/gradient_bg_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../constants/page_route_constants.dart';
import '../../constants/string_constant.dart';
import '../../localdb/databasehelper.dart';
import '../../model/GroupListModal.dart';
import '../../model/recentchatconnectionslist_modal.dart';
import '../../network/repository/api_repository.dart';
import '../../sharedpref/preference_connector.dart';
// import '../../widget/gradient_bg_view.dart';
import '../bottom_navigation/bottom_navigaction_bar.dart';
import 'chat_screen.dart';
// import 'tabview.dart';
// import 'logs.dart';

class LandingScreen extends StatefulWidget {
  final String peerId;
  final bool isGroup;
  const LandingScreen({Key key, this.peerId, this.isGroup}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _loading = 0;
  Connections _user;
  List<Connections> _users = [];
  AgoraRtmClient _client;
  Groups _group;
  bool _hasBuildCalled = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  @override
  void dispose() {
    _client?.logout();
    _client?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _hasBuildCalled = true;
    if (_loading == 6) {
      return SplashScreen();
    }
    if (_loading == 5 || _loading == 1) {
      return const BottomNavbar(
        index: 2,
        // rtmpeerid: widget.peerId,
      );
    }

    return WillPopScope(
      onWillPop: () {
        return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const BottomNavbar(index: 2)),
            (Route<dynamic> route) => false);
      },
      child: _loading == 0
          ? Scaffold(
              body: Container(
                height: double.infinity,
                color: AppColors.colorBg,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      Image.asset('assets/images/bvidhya.png'),
                    ],
                  ),
                ),
              ),
            )
          : _loading == 3 && _group != null
              ? GroupChatScreen(
                  client: _client,
                  rtmpeerid: _group.members[0].pid,
                  membersList: _group.members,
                  recentchatuserdetails: _group,
                  self: _group.self,
                  isDirect: true,
                )
              : _loading == 2
                  ? Chat_Screen(
                      client: _client,
                      rtmpeerid: widget.peerId,
                      recentchatuserdetails: _user,
                      status: _user.status,
                      userlist: _users,
                    )
                  : const Scaffold(
                      body: GradientColorBgView(
                        child: Center(
                          child: Text(
                            'No chat found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
    );
  }

  _openChatScreen(String peerId, bool isGroup) async {
    debugPrint('opening chat screen items :$peerId');
    const String appId = "d6306b59624c4e458883be16f5e6cbd2";
    try {
      try {
        _client = await AgoraRtmClient.createInstance(appId);
      } catch (_errr) {
        print('_client login error' + _errr);
      }
      final value = await PreferenceConnector.getJsonToSharedPreferencetoken(
          StringConstant.loginData);
      final result = await ApiRepository().Messanger_rtmtoken(value);
      if (result != null && result.status == "successfull") {
        await _client.login(result.body.rtmToken, result.body.rtmUser);

        final dbHelper = DatabaseHelper.instance;
        if (isGroup) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('groupbadge', false);
          List<Groups> _groups = await dbHelper.getAllgroupdata();
          Groups selectedGroup;
          if (_groups?.isNotEmpty == true) {
            selectedGroup =
                _groups.firstWhere((row) => row.groupName == peerId);
          }

          if (selectedGroup == null) {
            final list = await ApiRepository().groupList(value);
            if (list != null) {
              _groups = list.body.groups;
              selectedGroup =
                  _groups.firstWhere((row) => row.groupName == peerId);
            }
          } else {
            debugPrint('Found group: ${selectedGroup.toJson()}');
          }
          if (selectedGroup != null) {
            _group = selectedGroup;
            _loading = 3;
            if (_hasBuildCalled) {
              setState(() {});
            }
            return;
          }
          _loading = 1;
          if (_hasBuildCalled) {
            setState(() {});
          }
          return;
        } else {
          Connections selectedUser;
          _users = await dbHelper.getAlldata();
          if (_users?.isNotEmpty == true) {
            selectedUser = _users.firstWhere((row) => row.peerId == peerId);
          }

          if (selectedUser == null) {
            final value2 = await ApiRepository().recentconnection(value);
            if (value2 != null && value2.status == 'successfull') {
              _users = value2.body.connections;
              selectedUser = _users.firstWhere((row) => row.peerId == peerId);
            }
          }
          if (selectedUser != null) {
            _user = selectedUser;
            _loading = 2;
            if (_hasBuildCalled) {
              setState(() {});
            }
            return;
          }
        }
      }
    } catch (errorCode) {
      debugPrint('Login error: ' + errorCode.toString());

      _loading = 5;
      if (_hasBuildCalled) {
        setState(() {});
      }
      return;
    }
    _loading = 1;
    if (_hasBuildCalled) {
      setState(() {});
    }
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;
    debugPrint("IsLogin $isLogin");
    if (isLogin) {
      _openChatScreen(widget.peerId, widget.isGroup);
      //   Navigator.of(context).pushNamedAndRemoveUntil(
      //       PageRouteConstants.bottom_navigaction,
      //       (Route<dynamic> route) => false);
      // }
    } else {
      _loading = 6;
      if (_hasBuildCalled) {
        setState(() {});
      }
    }
  }

  // _openGroupChatScreen(String groupName) async {
  //   debugPrint('opening chat screen items');
  //   const String appId = "d6306b59624c4e458883be16f5e6cbd2";
  //   _client = await AgoraRtmClient.createInstance(appId);
  //   try {
  //     final value = await PreferenceConnector.getJsonToSharedPreferencetoken(
  //         StringConstant.loginData);
  //     final list = await ApiRepository().groupList(value);
  //     if (list != null) {
  //       List<Groups> _groups = list.body.groups;
  //       final selectedGroup =
  //           _groups.where((row) => row.groupName == groupName)?.first;
  //       if (selectedGroup != null) {
  //         _group = selectedGroup;
  //         _loading = 3;
  //         if (_hasBuildCalled) {
  //           setState(() {});
  //         }
  //         return;
  //       }
  //     }
  //   } catch (errorCode) {
  //     debugPrint('Login error: ' + errorCode.toString());
  //   }
  //   _loading = 1;
  // }
}
