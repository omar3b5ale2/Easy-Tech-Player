import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../core/utils/constants/app_colors.dart';
import '../../managers/cubit/navigation_cubit.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, state) {
        double fontSize = ResponsiveValue(
          context,
          defaultValue: 12.0,
          conditionalValues: [
            Condition.smallerThan(name: MOBILE, value: 10.0),
            Condition.largerThan(name: TABLET, value: 14.0),
          ],
        ).value;

        double iconSize = ResponsiveValue(
          context,
          defaultValue: 24.0,
          conditionalValues: [
            Condition.smallerThan(name: MOBILE, value: 20.0),
            Condition.largerThan(name: TABLET, value: 28.0),
          ],
        ).value;

        return BottomNavigationBar(
          backgroundColor: AppColors.darkBlue,
          currentIndex: state,
          onTap: (index) {
            context.read<NavigationCubit>().changeTab(index);
          },
          type: BottomNavigationBarType.fixed, // Ensures fixed tabs
          elevation: 10, // Adds slight shadow for better visibility
          selectedFontSize: fontSize, // Responsive font size
          unselectedFontSize: fontSize - 1,
          selectedItemColor: AppColors.teal, // Customize selected label color
          unselectedItemColor: Colors.grey, // Customize unselected label color
          // Slightly smaller for unselected
          items: [
            _buildBottomNavigationBarItem(
                icon: Icons.home,
                label: "Home",
                index: 0,
                currentState: state,
                iconSize: iconSize,
                color: Colors.grey
            ),
            _buildBottomNavigationBarItem(
                icon: Icons.ondemand_video_sharp,
                label: "Player",
                index: 1,
                currentState: state,
                iconSize: iconSize+15,
                color: Colors.red
            ),
            // _buildBottomNavigationBarItem(
            //     icon: Icons.history_rounded,
            //     label: "History",
            //     index: 2,
            //     currentState: state,
            //     iconSize: iconSize,
            //     color: Colors.grey
            // ),
          ],
        );
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentState,
    required double iconSize,
    required Color color
  }) {
    final bool isSelected = currentState == index;
    return BottomNavigationBarItem(
      icon: isSelected
          ? Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.teal,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize, // Adjusted size for responsiveness
        ),
      )
          : Icon(
        icon,
        color: color,
        size: iconSize, // Adjusted size for responsiveness
      ),
      label: label,

    );
  }
}
