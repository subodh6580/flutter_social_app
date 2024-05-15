import 'package:intl/intl.dart';

class VerificationRequest {
  int id = 0;
  String userMessage = '';
  String? adminMessage = '';

  int status = 0;
  int createdAt = 0;
  int? updatedAt;

  VerificationRequest({
    required this.id,
    required this.status,
    required this.userMessage,
    required this.adminMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) =>
      VerificationRequest(
        id: json["id"],
        status: json["status"],
        userMessage: json["user_message"],
        adminMessage: json["admin_message"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  String get sentOn {
    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(createdAt * 1000));
  }

  bool get isProcessing {
    return status == 1;
  }

  bool get isCancelled {
    return status == 2;
  }

  bool get isRejected {
    return status == 3;
  }

  bool get isApproved {
    return status == 10;
  }
}
