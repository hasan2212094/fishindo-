class IkanModel {
  final int id;
  final String name;

  IkanModel({required this.id, required this.name});

  factory IkanModel.fromJson(Map<String, dynamic> json) {
    return IkanModel(id: json['id'] ?? 0, name: json['name']?.toString() ?? '');
  }
}
