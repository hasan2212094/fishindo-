class SuccessModel {
  final String message;

  SuccessModel({required this.message});

  factory SuccessModel.fromJson(Map<String, dynamic> json) {
    return SuccessModel(message: json['message']);
  }
}
