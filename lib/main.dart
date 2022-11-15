import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:agora_rtm/agora_rtm.dart';
// import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:evidya/constants/string_constant.dart';
import 'package:evidya/model/chat_model.dart';

import 'package:evidya/screens/messenger/calls/audiocallscreen.dart';
import 'package:evidya/screens/messenger/landing_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:evidya/utils/AppErrorWidget.dart';
import 'package:flutter/services.dart';

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:evidya/localdb/databasehelper.dart';
import 'package:evidya/network/repository/api_repository.dart';
import 'package:evidya/notificationservice/LocalNotificationService.dart';
import 'package:evidya/resources/app_colors.dart';
import 'package:evidya/screens/splash/splash_screen.dart';
import 'package:evidya/sharedpref/preference_connector.dart';
import 'package:evidya/utils/helper.dart';
import 'package:evidya/utils/screen_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:sizer/sizer.dart';
// import 'constants/string_constant.dart';
import 'firebase_options.dart';
import 'localization/app_translations_delegate.dart';
import 'localization/application.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/messenger/calls/videocallscreen.dart';
import 'screens/messenger/logs.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:evidya/resources/bvidya_callkit_incoming.dart';
// import 'screens/messenger/tabview.dart';

const int callFree = 0;
const int callOnGroing = 20;
const int callEnd = 10;

final LogController chatLogController = LogController();
final GroupLongController groupChatLogController = GroupLongController();
final MessageLog messageLog = MessageLog();
final GroupMessageLog groupMessageLog = GroupMessageLog();

showOnLock(bool show) async {
  const String methodChannel = 'Lockscreen flag';
  const platform = MethodChannel(methodChannel);
  await platform.invokeMethod('startNewActivity', {
    'flag': show ? 'on' : 'off',
  });
}

Future<ChatModel> _handleChatModelMessege(String text) async {
  ChatModel model;
  if (text.startsWith('{')) {
    try {
      model = ChatModel.fromJson(jsonDecode(text));
      model.diraction = 'Receive';
      if (model.group != null && model.group.isNotEmpty) {
        // if (model.type == 'image') {
        // model.type = 'image';
        // }
        int id = await _insertGroupToDb(model.to, model);
        if (id > 0) {
          SharedPreferencesAndroid.registerWith();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('groupbadge', true);
        } else {
          // return null;
        }
      } else {
        // if (model.type == 'image') {
        //   model.type = 'network';
        // }
        int id = await _insertToDb(model.to, model);
        if (id < 0) {
          // return null;
        }
      }
      return model;
    } on Exception catch (e) {
      debugPrint('Error in parsing data $e');
    }
  }
  return model;
}

void insertLocaldataFromFirebase(
    RemoteMessage message, bool showNotification) async {
  ChatModel model = await _handleChatModelMessege(message.data['body']);

  if (model != null) {
    if (model.group?.isNotEmpty == true) {
      groupChatLogController.addLog(model);
    } else {
      chatLogController.addLog(model);
    }
    debugPrint('model  found $showNotification');
    if (showNotification) {
      LocalNotificationService.showNotificationModel(model, message);
    }
    return;
  }
  debugPrint('model not found');
  if (showNotification) {
    // LocalNotificationService.showNotification(message);
  }
}

void _callcutSpref() async {
  await FlutterCallkitIncoming.endAllCalls();
  // await BVidyaCallkitIncoming.endAllCalls();
  SharedPreferencesAndroid.registerWith();
  final prefs = await SharedPreferences.getInstance();
  PreferenceConnector().setcall('callscreen');
  await prefs.setInt('audio_call', callEnd);
  await prefs.setInt('video_call', callEnd);
}

_insertGroupToDb(String peerid, ChatModel model) async {
  // row to insert
  Map<String, dynamic> row = {
    DatabaseHelper.Id: null,
    DatabaseHelper.message: model.message,
    DatabaseHelper.timestamp: model.timestamp,
    DatabaseHelper.diraction: 'Receive',
    DatabaseHelper.type: model.type,
    DatabaseHelper.reply: model.reply,
    DatabaseHelper.from: model.from,
    DatabaseHelper.replyText: model.replyText,
    DatabaseHelper.to: peerid ?? '',
    DatabaseHelper.groupname: model.group,
    DatabaseHelper.textId: model.textId,
    DatabaseHelper.url: model.url ?? ''
  };
  final dbHelper = DatabaseHelper.instance;
  final id = await dbHelper.groupinsert(row);
  debugPrint(' inserted row id: $id');
  return id;
}

_insertToDb(String peerid, ChatModel model) async {
  // row to insert
  Map<String, dynamic> row = {
    DatabaseHelper.Id: null,
    DatabaseHelper.message: model.message,
    DatabaseHelper.timestamp: model.timestamp,
    DatabaseHelper.diraction: 'Receive',
    DatabaseHelper.type: model.type,
    DatabaseHelper.reply: model.reply,
    DatabaseHelper.replyText: model.replyText,
    DatabaseHelper.from: model.from,
    DatabaseHelper.to: peerid,
    DatabaseHelper.deliveryStatus: 'Undelivered',
    DatabaseHelper.textId: model.textId,
    DatabaseHelper.url: model.url
  };
  final dbHelper = DatabaseHelper.instance;
  final id = await dbHelper.insert(row);
  debugPrint('MA inserted row id: $id ${model.message}');
  return id;
}

void fcmapicall({String msg, String fcmtoken, String callId, String type}) {
  Helper.checkConnectivity().then((value) => {
        if (value)
          {
            ApiRepository()
                .sendFCMCallTrigger(
                    callId: callId,
                    myFcmToken: '',
                    userProfileUrl: '',
                    body: msg,
                    type: type,
                    action: 'call_declined',
                    otherUserFcmToken: fcmtoken,
                    title: 'Call cancelled',
                    fromId: '')
                .then(
              (value) async {
                if (value != null) {
                  debugPrint(value.toJson().toString());
                }
              },
            ),
          }
        else
          {
            //Helper.showNoConnectivityDialog(context)
          }
      });
}

Future<void> callinsert(
    String calleeName, String calltype, CallType type, String callId) async {
  // row to insert
  Map<String, dynamic> row = {
    DatabaseHelper.Id: null,
    DatabaseHelper.calleeName: calleeName,
    DatabaseHelper.timestamp: DateTime.now().toString(),
    DatabaseHelper.calltype: calltype,
    DatabaseHelper.Calldrm: type.name,
    DatabaseHelper.Callid: callId
  };
  final dbHelper = DatabaseHelper.instance;
  try {
    final id = await dbHelper.callinsert(row);
    debugPrint('inserted row id: $id');
  } catch (_) {}
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  print('listen a terminate message ${message.data}');

  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  final type = message.data['type'];
  if (type == 'basic_channel') {
    // LocalNotificationService.showNotification(message);
    insertLocaldataFromFirebase(message, true);
  } else if (type == 'call_channel') {
    // debugPrint('listen a background and not terminated message123 ${message.data}');
    LocalNotificationService.callkitNotification(message);

    SharedPreferencesAndroid.registerWith();
    // final prefs = await SharedPreferences.getInstance();
    SharedPreferences.getInstance().then((value) {
      value.setInt('audio_call', callFree);
      value.setInt('video_call', callFree);
    });
    //    prefs.setInt('audio_call', callFree);
    //    prefs.setInt('video_call', callFree);
  } else if (type == 'cut') {
    // await FlutterCallkitIncoming.endAllCalls();
    _callcutSpref();
  }
}

Future<void> main() async {
  // In dev mode, show error details
  // In release builds, show a only custom error message
  bool isDev = kDebugMode;
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return AppErrorWidget(
      errorDetails: errorDetails,
      isDev: isDev,
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // 3. This method only call when App in background and not terminated(not closed)
  FirebaseMessaging.onMessageOpenedApp.listen(
    (message) async {
      debugPrint(
          'listen a background and not terminated message ${message.data}');
      if (message.data != null) {
        SharedPreferencesAndroid.registerWith();
        if (message.data['type'] == 'basic_channel') {
          // downloadFromFirebase(message);
          insertLocaldataFromFirebase(message, false);
          // insert(message.data['body'],message.data['senderpeerid'], 'text',message.data['datetime'],message.data['receiverpeerid'],message.data['textid']);
          // LocalNotificationService.showNotification(message);
        } else if (message.data['type'] == 'call_channel') {
          //Vibrate.vibrate();
          final prefs = await SharedPreferences.getInstance();
          if (prefs.getInt('audio_call') == callOnGroing ||
              prefs.getInt('video_call') == callOnGroing) {
            LocalNotificationService.misscallkitNotification(message);
            return;
          }

          await prefs.setInt('audio_call', callFree);
          await prefs.setInt('video_call', callFree);
          LocalNotificationService.callkitNotification(message);
          //  LocalNotificationService.misscallkitNotification(message);
        } else if (message.data['type'] == 'cut') {
          _callcutSpref();
        }
      }
    },
  );

  AwesomeNotifications().initialize(
    null /*'resource://drawable/res_app_icon'*/,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF800000),
        enableLights: true,
        channelShowBadge: true,
        importance: NotificationImportance.Max,
        ledColor: Colors.white,
      ),
      NotificationChannel(
        channelGroupKey: 'category_tests',
        channelKey: 'call_channel',
        channelName: 'call_channel',
        enableVibration: true,
        channelDescription: 'Channel with call ringtone',
        defaultColor: const Color(0xFF800000),
        importance: NotificationImportance.Max,
        ledColor: Colors.white,
        channelShowBadge: true,
        locked: true,
        soundSource: 'resource://raw/telephone',
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupkey: 'basic_tests',
        channelGroupName: 'Basic tests',
      ),
      NotificationChannelGroup(
        channelGroupkey: 'category_tests',
        channelGroupName: 'Category tests',
      ),
    ],
    debug: isDev,
  );

  runApp(const ResponsiveApp());
}

class ResponsiveApp extends StatelessWidget {
  const ResponsiveApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sizer',
          theme: ThemeData.light().copyWith(
            textTheme: GoogleFonts.assistantTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: const BVidyaApp(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

class BVidyaApp extends StatefulWidget {
  const BVidyaApp({Key key}) : super(key: key);

  @override
  State<BVidyaApp> createState() => BVidyaAppState();
}

class BVidyaAppState extends State<BVidyaApp> with WidgetsBindingObserver {
  AppTranslationsDelegate _newLocaleDelegate;
  final dbHelper = DatabaseHelper.instance;
  // var appstate = true;
  bool background = false;
  String _currentUuid, _currentname, _currentcalltype, _fromId;
  // var _clicked = true;
  // ClassLog classlog = ClassLog();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    checkAndNavigationCallingPage();
    firebase();
    _newLocaleDelegate = const AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;
    AwesomeNotifications().actionStream.listen((receivedAction) {
      if (receivedAction.channelKey == 'basic_channel') {
        if (receivedAction.payload['from']?.isNotEmpty == true) {
          final code = receivedAction.payload['from'].hashCode;
          LocalNotificationService.clearPool(code);
        }
        if (receivedAction.payload['group'] == 'true') {
          // await Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) => MessengerTab(
          //           rtmpeerid: receivedAction.payload['name'],
          //         )));
          // if (!mounted) {
          //   print('Error in opening group chat');
          //   return;
          // }
          // Future.delayed(Duration.zero).then(
          // (value) =>
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LandingScreen(
                peerId: receivedAction.payload['name'],
                isGroup: true,
              ),
            ),
            // (route) => false,
            // ),
          );
        } else {
          // await Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (context) => MessengerTab(
          //           rtmpeerid: receivedAction.payload['peerid'],
          //         )));
          // if (!mounted) {
          //   print('Error in opening group chat');
          //   return;
          // }
          // Future.delayed(Duration.zero).then(
          // (value) =>
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LandingScreen(
                peerId: receivedAction.payload['fromId'],
                isGroup: false,
              ),
            ),
            // (route) => false,
            // ),
          );
        }
        // Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => messengertab(rtmpeerid: receivedAction.payload['peerid']),), (route) => false,//if you want to disable back feature set to false);
        return;
      }
    });

    FlutterCallkitIncoming.onEvent.listen((event) {
      debugPrint('onEvent:${event.name}');
      // EasyLoading.showToast('event:${event.name}',
      //     duration: const Duration(seconds: 2));
      switch (event.name) {
        case CallEvent.ACTION_CALL_ACCEPT:
          showOnLock(true);
          final callType = event.body['extra']['calltype'] ?? '';
          if (callType == 'video') {
            callinsert(event.body['extra']['username'], 'video',
                CallType.received, event.body['extra']['from_id']);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VideoCallScreen(
                  callid: event.body['extra']['callid'],
                  calleeName: event.body['username'],
                ),
              ),
            );
            // await AndroidForegroundService.stopForeground();
          } else if (callType == 'audio') {
            callinsert(
              event.body['extra']['username'],
              'audio',
              CallType.received,
              event.body['extra']['from_id'],
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AudioCallScreen(
                  callid: event.body['extra']['callid'],
                ),
              ),
            );
            // await AndroidForegroundService.stopForeground();
          }
          break;
        case CallEvent.ACTION_CALL_DECLINE:
          // showOnLock(false);
          callinsert(
            event.body['extra']['username'],
            event.body['extra']['calltype'],
            CallType.missed,
            event.body['extra']['from_id'],
          );
          if (!Platform.isAndroid) {
            fcmapicall(
              msg: 'call_cut',
              fcmtoken: event.body['extra']['fcmtoken'],
              callId: event.body['extra']['callid'],
              type: 'cut',
            );
          }
          break;
      }
    });
  }

  getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    // var calls2 = await BVidyaCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        _currentUuid = calls[0]['extra']['callid'];
        _currentname = calls[0]['extra']['username'];
        _currentcalltype = calls[0]['extra']['calltype'];
        _fromId = calls[0]['extra']['from_id'];
        return calls[0];
      } else {
        _currentUuid = '';
        return null;
      }
    }
  }

  checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      showOnLock(true);

      if (_currentcalltype == 'video') {
        callinsert(_currentUuid, 'video', CallType.received, _fromId);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => VideoCallScreen(
                callid: _currentUuid, calleeName: _currentname)));
      } else if (_currentcalltype == 'audio') {
        callinsert(_currentname, 'audio', CallType.received, _fromId);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return AudioCallScreen(callid: _currentUuid.toString());
        }));
        // AndroidForegroundService.stopForeground();
      }
    } else {
      await FlutterCallkitIncoming.endAllCalls();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // AndroidForegroundService.stopForeground();
    }
    if (state == AppLifecycleState.paused) {
      print('Hello I m here background');
      background = true;
    }

    if (state == AppLifecycleState.detached) {
      print('Hello I m here in termination');

      background = false;
    }
  }

  void firebase() async {
    // 1. This method only call when App in background it mean app must be closed
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) async {
        debugPrint('FirebaseMessaging.instance.getInitialMessage');
        if (message == null) return;
        if (message.data['type'] == 'basic_channel') {
          // downloadFromFirebase(message);
          debugPrint('data:${message.data}');
          insertLocaldataFromFirebase(message, false);
        } else if (message.data['type'] == 'call_channel') {
          SharedPreferencesAndroid.registerWith();
          final prefs = await SharedPreferences.getInstance();
          if (prefs.getInt('audio_call') == callOnGroing ||
              prefs.getInt('video_call') == callOnGroing) {
            LocalNotificationService.misscallkitNotification(message);
            return;
          }
          await prefs.setInt('audio_call', callFree);
          await prefs.setInt('video_call', callFree);
          //Vibrate.vibrate();
          // LocalNotificationService.showCallNotification(message.data);
          LocalNotificationService.callkitNotification(message);
          //  LocalNotificationService.misscallkitNotification(message);
        } else if (message.data['type'] == 'cut') {
          _callcutSpref();
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) async {
        //SharedPreferences prefs = await SharedPreferences.getInstance();
        // var chatUserName = prefs.getString('chatUserName') ?? '';
        // debugPrint('Chat User Name $chatUserName');
        debugPrint('listen a forground message ${message.data}');
        SharedPreferencesAndroid.registerWith();
        var type = message.data['type'];
        if (type == 'basic_channel') {
          // downloadFromFirebase(message);
          final prefs = await SharedPreferences.getInstance();
          final String action = prefs.getString('action');
          debugPrint('screenname :$action -- ${message.data['from_id']}');
          insertLocaldataFromFirebase(
            message,
            (action != message.data['from_id'] &&
                action != message.data['title']),
          );
        } else if (type == 'call_channel') {
          Vibrate.vibrate();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('audio_call', callFree);
          await prefs.setInt('video_call', callFree);
          LocalNotificationService.callkitNotification(message);
        } else if (type == 'cut') {
          _callcutSpref();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bVidya',
      theme: ThemeData(
        // primarySwatch: AppColors.redColor,
        primaryColor: AppColors.redColor,
        // accentColor: AppColors.chatYellow,
      ).copyWith(
        textTheme: GoogleFonts.assistantTextTheme(Theme.of(context).textTheme),
      ),
      onGenerateRoute: ScreenRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      localizationsDelegates: [
        _newLocaleDelegate,
        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
      ],
    );
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}
