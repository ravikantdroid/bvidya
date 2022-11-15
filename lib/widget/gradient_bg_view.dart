import 'package:flutter/material.dart';

import '../resources/app_colors.dart';

class GradientColorBgView extends StatelessWidget {
  final Widget child;
  const GradientColorBgView({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.appNewDarkThemeColor,
            AppColors.appNewLightThemeColor,
          ],
          stops: const [0.2, 0.8],
        ),
      ),
      child: child,
    );
  }
}
