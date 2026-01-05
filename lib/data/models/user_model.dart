class UserModel {
  final int id;
  final String name;
  final String email;
  final int roleid;
  final String rolename;
  

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleid,
    required this.rolename,
    
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleid: json['role_id'],
      rolename: json['role_name'],
      // createdAt: DateTime.parse(json['created_at']).toUtc().add(const Duration(hours: 7)),
    );
  }
}
