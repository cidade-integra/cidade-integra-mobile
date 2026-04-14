import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _maxFileSizeMb = 5;
const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const _bucket = 'reports';

class SupabaseService {
  final _storage = Supabase.instance.client.storage;

  Future<String> uploadImage(File file) async {
    final ext = file.path.split('.').last.toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      throw Exception('Tipo de arquivo inválido. Use JPG, PNG ou WEBP.');
    }

    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > _maxFileSizeMb) {
      throw Exception('Arquivo excede ${_maxFileSizeMb}MB.');
    }

    final fileName = 'public/${const Uuid().v4()}.$ext';

    await _storage.from(_bucket).upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final url = _storage.from(_bucket).getPublicUrl(fileName);
    return url;
  }
}
