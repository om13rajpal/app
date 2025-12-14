class FailureModel {
  const FailureModel({
    this.status = false,
    this.message,
    this.data,
    this.errors,
  });
  final bool status;
  final String? message;
  final String? data;
  final List<ErrorElement>? errors;
  factory FailureModel.fromJson(Map<String, dynamic> json) {
    return FailureModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? '',
      errors: json['errors'] == null
          ? []
          : List<ErrorElement>.from(
              (json['errors'] ?? []).map((x) => ErrorElement.fromJson(x)),
            ),
    );
  }
  static FailureModel networkError() {
    return const FailureModel(
      message: 'No internet connection',
    );
  }

  static FailureModel commonFailureModel({String? message}) {
    return FailureModel(
      message: message ?? 'Something went wrong! try later.',
    );
  }
}

class ErrorElement {
  final String? field;
  final String? message;
  ErrorElement({
    this.field,
    this.message,
  });
  factory ErrorElement.fromJson(Map<String, dynamic> json) => ErrorElement(
        field: json['field'],
        message: json['message'],
      );
  Map<String, dynamic> toJson() => {
        'field': field,
        'message': message,
      };
}
