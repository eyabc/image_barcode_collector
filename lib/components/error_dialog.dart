import 'package:flutter/material.dart';

import '../app.dart';


void showErrorDialog(String errorMessage) {
  showDialog(
    context: navigatorKey.currentState!.overlay!.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('I\'m Sorry'),
        content: Text(errorMessage),
      );
    },
  );
}