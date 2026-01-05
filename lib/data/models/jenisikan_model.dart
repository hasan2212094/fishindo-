class JenisIkanModel {
  final int id;
  final String name;

  JenisIkanModel({
    required this.id,
    required this.name,
  });

  factory JenisIkanModel.fromJson(Map<String, dynamic> json) {
    return JenisIkanModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
