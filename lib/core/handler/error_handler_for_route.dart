import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  const ErrorDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: const Text('Navigation Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/'); // Ensure GoRouter is used for navigation
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}