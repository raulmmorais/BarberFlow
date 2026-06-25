import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  LocalStorageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> captureAndSavePhoto(String agendamentoId) =>
      savePhoto(agendamentoId, source: ImageSource.camera);

  Future<String?> savePhoto(
    String agendamentoId, {
    ImageSource source = ImageSource.camera,
  }) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${directory.path}/barberflow_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final fileName =
        '${agendamentoId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${photosDir.path}/$fileName';
    await File(image.path).copy(savedPath);
    return savedPath;
  }
}
