import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarCubit extends Cubit<Animation<double>> {
  late AnimationController _controller;
  late Animation<double> _animation;

  AppBarCubit() : super(const AlwaysStoppedAnimation(0.5));

  void initAnimation(TickerProvider vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Emit the animation value to the UI
    emit(_animation);
  }

  @override
  Future<void> close() {
    _controller.dispose();
    return super.close();
  }
}