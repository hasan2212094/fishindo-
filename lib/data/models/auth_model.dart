class AuthModel {
  final int id;
  final String name;
  final String email;
  final int roleid;
  final String rolename;
  final String token;

  AuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleid,
    required this.rolename,
    required this.token,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleid: json['role_id'],
      rolename: json['role_name'],
      token: json['token'],
    );
  }
}
