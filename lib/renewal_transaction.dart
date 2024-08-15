class RenewalTransaction {
  final int expirationIntent;
  final String originalTransactionId;
  final String autoRenewProductId;
  final String productId;
  final int autoRenewStatus;
  final bool isInBillingRetryPeriod;
  final int signedDate;
  final String environment;
  final int recentSubscriptionStartDate;
  final int renewalDate;

  RenewalTransaction({
    required this.expirationIntent,
    required this.originalTransactionId,
    required this.autoRenewProductId,
    required this.productId,
    required this.autoRenewStatus,
    required this.isInBillingRetryPeriod,
    required this.signedDate,
    required this.environment,
    required this.recentSubscriptionStartDate,
    required this.renewalDate,
  });

  factory RenewalTransaction.fromJson(Map<String, dynamic> json) {
    return RenewalTransaction(
      expirationIntent: json['expirationIntent'] ?? 0,
      originalTransactionId: json['originalTransactionId'] ?? '',
      autoRenewProductId: json['autoRenewProductId'] ?? '',
      productId: json['productId'] ?? '',
      autoRenewStatus: json['autoRenewStatus'] ?? 0,
      isInBillingRetryPeriod: json['isInBillingRetryPeriod'] ?? false,
      signedDate: json['signedDate'] ?? 0,
      environment: json['environment'] ?? 0,
      recentSubscriptionStartDate: json['recentSubscriptionStartDate'] ?? 0,
      renewalDate: json['renewalDate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expirationIntent': expirationIntent,
      'originalTransactionId': originalTransactionId,
      'autoRenewProductId': autoRenewProductId,
      'productId': productId,
      'autoRenewStatus': autoRenewStatus,
      'isInBillingRetryPeriod': isInBillingRetryPeriod,
      'signedDate': signedDate,
      'environment': environment,
      'recentSubscriptionStartDate': recentSubscriptionStartDate,
      'renewalDate': renewalDate,
    };
  }
}
