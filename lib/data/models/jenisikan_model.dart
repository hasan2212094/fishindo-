class JenisIkanModel {
  final int id;
  final String name;
  final bool isMain;

  JenisIkanModel({required this.id, required this.name, required this.isMain});

  factory JenisIkanModel.fromJson(Map<String, dynamic> json) {
    return JenisIkanModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      isMain: json['is_main'] == 1 || json['is_main'] == true,
    );
  }
}
