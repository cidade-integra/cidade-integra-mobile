import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const _maxFileSizeMb = 5;
const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const _bucket = 'reports';

class UploadException implements Exception {
  final String userMessage;
  final Object? cause;
  UploadException(this.userMessage, {this.cause});

  @override
  String toString() => userMessage;
}

class SupabaseService {
  final _storage = Supabase.instance.client.storage;

  Future<String> uploadImage(File file) async {
    final ext = file.path.split('.').last.toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      throw UploadException('Tipo de arquivo inválido. Use JPG, PNG ou WEBP.');
    }

    final sizeInMb = file.lengthSync() / (1024 * 1024);
    if (sizeInMb > _maxFileSizeMb) {
      throw UploadException('A imagem excede o limite de ${_maxFileSizeMb}MB.');
    }

    final fileName = 'public/${const Uuid().v4()}.$ext';

    try {
      await _storage
          .from(_bucket)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final url = _storage.from(_bucket).getPublicUrl(fileName);
      debugPrint('[SupabaseService] Upload OK: $url');
      return url;
    } on StorageException catch (e, stack) {
      debugPrint('[SupabaseService] StorageException: ${e.statusCode} ${e.message}');
      debugPrintStack(stackTrace: stack);

      final code = e.statusCode?.toString() ?? '';
      if (code == '403' || e.message.contains('row-level security')) {
        throw UploadException(
          'Sem permissão para enviar imagens. Verifique se você está autenticado.',
          cause: e,
        );
      }
      if (code == '413') {
        throw UploadException('Imagem muito grande para o servidor.', cause: e);
      }
      if (code.startsWith('5')) {
        throw UploadException(
          'Servidor de imagens indisponível. Tente novamente em instantes.',
          cause: e,
        );
      }
      throw UploadException(
        'Falha ao enviar imagem. Tente novamente.',
        cause: e,
      );
    } on SocketException catch (e, stack) {
      debugPrint('[SupabaseService] SocketException: $e');
      debugPrintStack(stackTrace: stack);
      throw UploadException(
        'Sem conexão com a internet. Verifique sua rede.',
        cause: e,
      );
    } catch (e, stack) {
      debugPrint('[SupabaseService] Erro inesperado: $e');
      debugPrintStack(stackTrace: stack);
      throw UploadException(
        'Erro inesperado ao enviar imagem.',
        cause: e,
      );
    }
  }
}
