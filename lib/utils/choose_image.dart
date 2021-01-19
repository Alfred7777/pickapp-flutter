import 'dart:io';
import 'package:PickApp/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChooseImage {
  // ignore: missing_return
  static Future<ImageSource> chooseImageSource() async {
    var _result = await showModalBottomSheet(
      context: navigatorKey.currentContext,
      builder: (context) {
        return ChooseSourceModalSheet();
      },
    );
    if (_result == 'Camera') {
      var _status = await Permission.camera.request();
      if (_status.isGranted) {
        return ImageSource.camera;
      } else if (_status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        return null;
      }
    } else if (_result == 'Gallery') {
      if (Platform.isIOS) {
        var _status = await Permission.photos.request();
        if (_status.isGranted) {
          return ImageSource.gallery;
        } else if (_status.isPermanentlyDenied) {
          await openAppSettings();
        } else {
          return null;
        }
      } else {
        var _status = await Permission.storage.request();
        if (_status.isGranted) {
          return ImageSource.gallery;
        } else if (_status.isPermanentlyDenied) {
          await openAppSettings();
        } else {
          return null;
        }
      }
    } else {
      return null;
    }
  }

  static Future<PickedFile> chooseImage(ImageSource source) async {
    final _picker = ImagePicker();

    return _picker.getImage(
      source: source,
      maxHeight: 650,
      maxWidth: 650,
    );
  }
}

class ChooseSourceModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              left: 8,
              right: 8,
            ),
            child: Text(
              'Upload from:',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          OptionRow(
            icon: Icons.camera_alt,
            label: 'Camera',
          ),
          OptionRow(
            icon: Icons.collections,
            label: 'Gallery',
          ),
        ],
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const OptionRow({
    @required this.icon,
    @required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, label);
      },
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              left: 12,
              right: 8,
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
