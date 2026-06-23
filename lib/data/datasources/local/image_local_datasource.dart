import 'package:barberflow/core/services/local_storage_service.dart';

class ImageLocalDatasource {
  ImageLocalDatasource({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  final LocalStorageService _storage;

  Future<String?> capturePhoto(String agendamentoId) {
    return _storage.captureAndSavePhoto(agendamentoId);
  }
}
