import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ReportStatus { pending, review, resolved, rejected }

enum ReportCategory { buracos, iluminacao, lixo, vazamentos, areasVerdes, outros }

class ReportLocation {
  final double? latitude;
  final double? longitude;
  final String address;
  final String? postalCode;

  const ReportLocation({
    this.latitude,
    this.longitude,
    this.address = '',
    this.postalCode,
  });

  factory ReportLocation.fromMap(Map<String, dynamic> map) {
    return ReportLocation(
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] ?? '',
      postalCode: map['postalCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'postalCode': postalCode,
    };
  }
}

class Report {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final bool isAnonymous;
  final String? userId;
  final ReportLocation location;
  final List<String> imageUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isAnonymous,
    this.userId,
    required this.location,
    this.imageUrls = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ReportCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ReportCategory.outros,
      ),
      isAnonymous: data['isAnonymous'] ?? false,
      userId: data['userId'],
      location: ReportLocation.fromMap(
        data['location'] is Map<String, dynamic>
            ? data['location']
            : <String, dynamic>{},
      ),
      imageUrls: List<String>.from(data['imagemUrls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
      resolvedAt:
          data['resolvedAt'] != null ? _toDateTime(data['resolvedAt']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'isAnonymous': isAnonymous,
      'userId': userId,
      'location': location.toMap(),
      'imagemUrls': imageUrls,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt':
          resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

extension ReportStatusLabel on ReportStatus {
  String get label {
    const labels = {
      ReportStatus.pending: 'Pendente',
      ReportStatus.review: 'Em Análise',
      ReportStatus.resolved: 'Resolvida',
      ReportStatus.rejected: 'Rejeitada',
    };
    return labels[this]!;
  }

  Color get color {
    const colors = {
      ReportStatus.pending: Color(0xFFF39C12),
      ReportStatus.review: Color(0xFF3498DB),
      ReportStatus.resolved: Color(0xFF2ECC71),
      ReportStatus.rejected: Color(0xFFE74C3C),
    };
    return colors[this]!;
  }

  Color get backgroundColor {
    const colors = {
      ReportStatus.pending: Color(0xFFFFF3CD),
      ReportStatus.review: Color(0xFFD6EAF8),
      ReportStatus.resolved: Color(0xFFD5F5E3),
      ReportStatus.rejected: Color(0xFFFADCD5),
    };
    return colors[this]!;
  }
}

extension ReportCategoryLabel on ReportCategory {
  String get label {
    const labels = {
      ReportCategory.buracos: 'Buracos',
      ReportCategory.iluminacao: 'Iluminação',
      ReportCategory.lixo: 'Lixo',
      ReportCategory.vazamentos: 'Vazamentos',
      ReportCategory.areasVerdes: 'Áreas Verdes',
      ReportCategory.outros: 'Outros',
    };
    return labels[this]!;
  }

  IconData get icon {
    const icons = {
      ReportCategory.buracos: 0xe3b6, // Icons.warning
      ReportCategory.iluminacao: 0xe3a9, // Icons.lightbulb
      ReportCategory.lixo: 0xe1bb, // Icons.delete
      ReportCategory.vazamentos: 0xe798, // Icons.water_drop
      ReportCategory.areasVerdes: 0xe3be, // Icons.park
      ReportCategory.outros: 0xe3c0, // Icons.more_horiz
    };
    return IconData(icons[this]!, fontFamily: 'MaterialIcons');
  }
}
