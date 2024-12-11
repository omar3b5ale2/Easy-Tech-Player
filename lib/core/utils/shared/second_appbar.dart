import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class SecondAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  @override
  final Size preferredSize;

  SecondAppBar({super.key, required this.text})
      : preferredSize = Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
        style: AppConstants.titleTextStyle,
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            height: 40.0,
            width: 40.0,
            child: Image.asset('assets/icon/logo.png')),
      ),
      centerTitle: true,
      elevation: AppConstants.appBarElevation,
      backgroundColor: AppColors.darkBlue,
      shadowColor: AppConstants.shadowColor,
    );
  }
}
