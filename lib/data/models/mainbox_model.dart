class MainBoxModel {
  final int id;
  final String name;

  MainBoxModel({required this.id, required this.name});

  factory MainBoxModel.fromJson(Map<String, dynamic> json) {
    return MainBoxModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
