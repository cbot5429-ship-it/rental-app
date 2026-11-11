import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  static final _db = Supabase.instance.client;
  static final _picker = ImagePicker();

    static Future<XFile?> pickSingle() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  }

  static Future<List<XFile>> pickMultiple() async {
    // Pick up to 5 images
    return await _picker.pickMultiImage(imageQuality: 70, limit: 5);
  }

  static Future<List<String>> uploadAll(List<XFile> files, String ownerId) async {
    final urls = <String>[];
    for (final f in files) {
      final Uint8List bytes = await f.readAsBytes();
      // Create a unique filename
      final path = '$ownerId/${DateTime.now().microsecondsSinceEpoch}_${f.name}';
      
      await _db.storage.from('property-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
          
      urls.add(_db.storage.from('property-images').getPublicUrl(path));
    }
    return urls;
  }
}