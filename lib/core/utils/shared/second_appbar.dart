import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class SecondAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final bool showReturnButton; // New parameter for optional return button
  @override
  final Size preferredSize;

  SecondAppBar({
    super.key,
    required this.text,
    this.showReturnButton = false, // Default to false
  }) : preferredSize = const Size.fromHeight(56.0);

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
      leading: showReturnButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          // Use GoRouter to navigate back
          context.pop();
        },
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: Image.asset('assets/icon/logo.png'),
        ),
      ),
      centerTitle: true,
      elevation: AppConstants.appBarElevation,
      backgroundColor: AppColors.darkBlue,
      shadowColor: AppConstants.shadowColor,
    );
  }
}