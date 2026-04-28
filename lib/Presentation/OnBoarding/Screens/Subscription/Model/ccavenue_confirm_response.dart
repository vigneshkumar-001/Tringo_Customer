import 'subscription_current_response.dart';

class CcavenueConfirmResponse {
  final bool status;
  final String? message;

  /// Backend returns rich subscription state for success/pending/cancelled.
  final SubscriptionCurrentData? data;

  /// Payment outcome (SUCCESS/PENDING/CANCELLED/FAILED)
  final String? paymentStatus;
  final String? orderId;
  final String? orderStatusLabel;
  final String? referenceNo;

  const CcavenueConfirmResponse({
    required this.status,
    this.message,
    this.data,
    this.paymentStatus,
    this.orderId,
    this.orderStatusLabel,
    this.referenceNo,
  });

  factory CcavenueConfirmResponse.fromJson(Map<String, dynamic> json) {
    return CcavenueConfirmResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? SubscriptionCurrentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      paymentStatus: json['paymentStatus']?.toString(),
      orderId: json['orderId']?.toString(),
      orderStatusLabel: json['orderStatusLabel']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
    );
  }
}

