class SuccessModel {
  final bool success;
  final String? message;
  final dynamic data;
  const SuccessModel({
    this.success = false,
    this.message,
    this.data,
  });
  factory SuccessModel.fromJson(Map<String, dynamic> json) => SuccessModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] ?? '',
      );
}
