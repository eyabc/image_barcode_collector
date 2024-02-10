import 'dart:io';

import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  File? file;
  ImageView({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Image View'),
          centerTitle: true,
          elevation: 0,
        ),
        body:  Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(file!),
          ],
        ),
    );
  }
}
