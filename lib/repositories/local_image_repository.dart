import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../entities/vehicle_image.dart';

/// Class for read/write on image files for [VehicleImage] objects
class LocalImageRepository {
  /// Default constructor
  const LocalImageRepository();

  /// Name for images directory
  static const String imagesDirName = 'images';

  /// Method to get path of images directory
  Future<String> getSavePath() async {
    // Application root directory
    final appDir = await getApplicationDocumentsDirectory();

    // Get images directory
    var imagesDir = Directory('${appDir.path}/$imagesDirName');

    // If doesn't exist, create
    if (!await imagesDir.exists()) {
      print('Creating folder for image repository: $imagesDirName');
      imagesDir = await imagesDir.create();
    }

    return imagesDir.path;
  }

  /// Method to save a given image
  Future<void> saveImage(File image) async {
    final savePath = await getSavePath();

    // Create file object for supposed path of the image
    final imageName = basename(image.path);
    final file = File('$savePath/$imageName');

    // Write image to path
    print('Writing to path ${file.path}');
    await file.writeAsBytes(await image.readAsBytes());
  }

  /// Method to load an image from a given name
  Future<File> loadImage(String imageName) async {
    final savePath = getSavePath();

    // Create file object
    final file = File('$savePath/$imageName');

    // If doesn't exist, throw error
    if (!await file.exists()) {
      throw FileSystemException(
        'Image $imageName not found',
        '$savePath/$imageName',
      );
    }

    return file;
  }
}
