import 'jenisikan_model.dart';

class FishindoModel {
  final int id;
  final int userIdBy;
  final String userByName;
  final String lokasi;
  final String nelayan;
  final double timbangan;
  final double harga;
  final JenisIkanModel? jenisikan;
  final List<String> imagesFish;
  final List<String> imagesTimbangan;
  final DateTime? createdAt;

  FishindoModel({
    required this.id,
    required this.userIdBy,
    required this.userByName,
    required this.lokasi,
    required this.nelayan,
    required this.timbangan,
    required this.harga,
    this.jenisikan,
    this.imagesFish = const [],
    this.imagesTimbangan = const [],
    this.createdAt,
  });

  factory FishindoModel.fromJson(Map<String, dynamic> json) {
    return FishindoModel(
      id: json['id'] ?? 0,
      userIdBy: json['user_id_by'] ?? 0,
      userByName: json['user_by_name']?.toString() ?? '',
      lokasi: json['lokasi'] ?? '',
      nelayan: json['nelayan'] ?? '',
      timbangan: (json['timbangan'] as num?)?.toDouble() ?? 0.0,
      harga: (json['harga'] as num?)?.toDouble() ?? 0.0,
      jenisikan: json['jenisikan'] != null
          ? JenisIkanModel.fromJson(
              json['jenisikan'] as Map<String, dynamic>,
            )
          : null,
      imagesFish: List<String>.from(json['images_fish'] ?? []),
      imagesTimbangan: List<String>.from(json['images_timbangan'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
