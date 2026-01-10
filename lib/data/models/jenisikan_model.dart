import 'ikan_model.dart';

class JenisIkanModel {
  final int id;
  final String name;
  final IkanModel? ikan;
  final DateTime? createdAt;

  JenisIkanModel({
    required this.id,
    required this.name,
    this.ikan,
    this.createdAt,
  });

  factory JenisIkanModel.fromJson(Map<String, dynamic> json) {
    return JenisIkanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      ikan: json['ikan'] != null ? IkanModel.fromJson(json['ikan']) : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }
}
