class IkanModel {
  final int id;
  final String name;
  final int status_kelompok;

  IkanModel({
    required this.id,
    required this.name,
    required this.status_kelompok,
  });

  factory IkanModel.fromJson(Map<String, dynamic> json) {
    return IkanModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      status_kelompok:
          json['status_kelompok'] is int
              ? json['status_kelompok']
              : int.tryParse(json['status_kelompok'].toString()) ?? 0,
    );
  }
}
