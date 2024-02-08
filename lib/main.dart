import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AssetEntity>? _imageList;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.authorized) {
      final assets = await PhotoManager.getAssetPathList(type: RequestType.image);
      if (assets.isNotEmpty) {
        final assetList = await assets[0].getAssetListRange(start: 0, end: 100); // Adjust the range as needed
        setState(() {
          _imageList = assetList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('iOS 갤러리 조회 '),
      ),
      body: _imageList == null
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _imageList!.length,
        itemBuilder: (context, index) {
          return ImageItem(assetEntity: _imageList![index]);
        },
      ),
    );
  }
}

class ImageItem extends StatelessWidget {
  final AssetEntity assetEntity;

  const ImageItem({Key? key, required this.assetEntity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?> (
      future: assetEntity.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.file(snapshot.data!);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}