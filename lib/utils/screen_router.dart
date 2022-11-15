import 'package:evidya/constants/page_route_constants.dart';
// import 'package:evidya/model/home.dart';
import 'package:evidya/screens/bottom_navigation/bottom_navigaction_bar.dart';
import 'package:evidya/screens/createmeet/schudle_meet_screen.dart';
import 'package:evidya/screens/login/forget_password.dart';
import 'package:evidya/screens/login/login_screen.dart';
import 'package:evidya/screens/login/registration_screen.dart';
import 'package:evidya/screens/splash/policy_discloser.dart';

import 'package:evidya/screens/splash/splash_screen.dart';

import 'package:evidya/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

// import '../screens/livestreaming/broadcast/audiocallpage.dart';

class ScreenRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case PageRouteConstants.home_screen:
      //   return MaterialPageRoute(builder: (_) => HomeScreen());
      case PageRouteConstants.splash_screen:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case PageRouteConstants.login_screen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case PageRouteConstants.welcome_screen:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case PageRouteConstants.policy_screen:
        return MaterialPageRoute(builder: (_) => Policy());
      case PageRouteConstants.registration_screen:
        return MaterialPageRoute(builder: (_) => RegistrationScreen());
      case PageRouteConstants.forget_password:
        return MaterialPageRoute(builder: (_) => ForgetPassword());
      case PageRouteConstants.bottom_navigaction:
        return MaterialPageRoute(builder: (_) => const BottomNavbar(index: 2));
      // case PageRouteConstants.audiocallscreen:
      //   return MaterialPageRoute(builder: (_) => AudioCallpage());
      case PageRouteConstants.schudle_meet_screen:
        return MaterialPageRoute(builder: (_) => const Schudle_Meet_Screen());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
