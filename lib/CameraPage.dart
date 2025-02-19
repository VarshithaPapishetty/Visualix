import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  Future<void> _takePicture(BuildContext context) async {
    final picker = ImagePicker();

    // Request storage permission
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isDenied) {
        // Show a message if permission is denied
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Storage permission denied. Cannot save image.'),
        ));
        return;
      }
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _handleImage(context, imageFile); // Handle the image for saving or retaking
    }
  }

  Future<void> _handleImage(BuildContext context, File imageFile) async {
    bool shouldRetake = false;

    do {
      shouldRetake = await _showImageCapturedDialog(context, imageFile);
      if (shouldRetake) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          imageFile = File(pickedFile.path); // Update the imageFile with the new image
        } else {
          shouldRetake = false; // Exit the loop if no new image is taken
        }
      }
    } while (shouldRetake);
  }

  Future<bool> _showImageCapturedDialog(BuildContext context, File imageFile) async {
    bool retakePressed = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Image Captured'),
        content: Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              _saveImage(imageFile, context); // Save the image
              retakePressed = false;
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              retakePressed = true; // Indicate that the user wants to retake
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Retake'),
          ),
        ],
      ),
    );

    return retakePressed;
  }

  Future<void> _saveImage(File image, BuildContext context) async {
    final result = await ImageGallerySaver.saveFile(image.path);

    if (result != null && result["filePath"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image saved successfully at ${result["filePath"]}'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save image.'),
      ));
    }

    Navigator.of(context).pop(); // Close the dialog after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _takePicture(context);
          },
          child: Text('Take Picture'),
        ),
      ),
    );
  }
}
