import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0); // Default to the first tab.

  void changeTab(int index) => emit(index);

  void resetToDefault() => emit(0);

  void openVideoPlayer() => emit(1);
}
