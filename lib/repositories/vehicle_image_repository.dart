import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../database/vehicle_image_table.dart';
import '../entities/vehicle_image.dart';

/// Class for [VehicleImage] table operations
class VehicleImageRepository {
  /// Default constructor
  const VehicleImageRepository();

  /// Name for images directory
  static const String imagesDirName = 'images';

  /// Insert a [VehicleImage] on the database [VehicleImageTable] table
  Future<int> insert(VehicleImage vehicleImage) async {
    final database = await getDatabase();
    final map = vehicleImage.toMap();

    return await database.insert(VehicleImageTable.tableName, map);
  }

  /// Method to get all [VehicleImage] objects in [VehicleImageTable]
  Future<List<VehicleImage>> select() async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleImageTable.tableName,
    );

    // Convert query items to [VehicleImage] objects
    final list = <VehicleImage>[];
    for (final item in result) {
      list.add(VehicleImage(
        id: item[VehicleImageTable.id],
        name: item[VehicleImageTable.name],
        vehicleId: item[VehicleImageTable.vehicleId],
      ));
    }

    return list;
  }

  /// Method to get a [VehicleImage] by given id
  Future<VehicleImage?> selectById(int id) async {
    final database = await getDatabase();

    // Query all items
    final List<Map<String, dynamic>> result = await database.query(
      VehicleImageTable.tableName,
      where: '${VehicleImageTable.id} = ?',
      whereArgs: [id],
    );

    // Check if exists
    if (result.isNotEmpty) {
      final item = result.first;
      return VehicleImage(
        id: item[VehicleImageTable.id],
        name: item[VehicleImageTable.name],
        vehicleId: item[VehicleImageTable.vehicleId],
      );
    }

    // If no result, return null
    return null;
  }

  /// Method to delete a specific [VehicleImage] from database
  Future<void> delete(VehicleImage vehicleImage) async {
    final database = await getDatabase();

    // TODO: Also delete image from images folder
    await database.delete(
      VehicleImageTable.tableName,
      where: '${VehicleImageTable.id} = ?',
      whereArgs: [vehicleImage.id],
    );
  }

  /// Method to get path of images directory
  Future<String> getSavePath() async {
    // Application root directory
    final appDir = await getApplicationDocumentsDirectory();

    // Get images directory
    var imagesDir = Directory('${appDir.path}/$imagesDirName');

    // If doesn't exist, create
    if (!await imagesDir.exists()) {
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
    await file.writeAsBytes(await image.readAsBytes());
  }

  /// Method to load an image from a given name
  Future<File> loadImage(String imageName) async {
    final savePath = await getSavePath();

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
