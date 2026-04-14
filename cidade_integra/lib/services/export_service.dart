import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_user.dart';
import '../models/report.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> exportReportsCSV(List<Report> reports) async {
    final buffer = StringBuffer();
    buffer.writeln('ID,Título,Categoria,Status,Data,Endereço,UserId');

    for (final r in reports) {
      buffer.writeln(
        '"${_escape(r.id)}",'
        '"${_escape(r.title)}",'
        '"${r.category.label}",'
        '"${r.status.label}",'
        '"${_dateFormat.format(r.createdAt)}",'
        '"${_escape(r.location.address)}",'
        '"${r.userId ?? "anônimo"}"',
      );
    }

    await _shareFile(buffer.toString(), 'denuncias.csv', 'Relatório de Denúncias');
  }

  Future<void> exportUsersCSV(List<AppUser> users) async {
    final buffer = StringBuffer();
    buffer.writeln('Nome,Email,Role,Status,Score,Denúncias,Cadastro');

    for (final u in users) {
      buffer.writeln(
        '"${_escape(u.displayName)}",'
        '"${_escape(u.email)}",'
        '"${u.role}",'
        '"${u.status}",'
        '"${u.score}",'
        '"${u.reportCount}",'
        '"${u.createdAt}"',
      );
    }

    await _shareFile(buffer.toString(), 'usuarios.csv', 'Relatório de Usuários');
  }

  Future<void> _shareFile(String content, String fileName, String subject) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject,
      ),
    );
  }

  String _escape(String value) => value.replaceAll('"', '""');
}
