class Transaction {
  final String transactionId;
  final String originalTransactionId;
  final String webOrderLineItemId;
  final String bundleId;
  final String productId;
  final String subscriptionGroupIdentifier;
  final int purchaseDate;
  final int originalPurchaseDate;
  final int expiresDate;
  final int quantity;
  final String type;
  final String inAppOwnershipType;
  final int signedDate;
  final String environment;
  final String transactionReason;
  final String storefront;
  final String storefrontId;
  final int price;
  final String currency;

  Transaction({
    required this.transactionId,
    required this.originalTransactionId,
    required this.webOrderLineItemId,
    required this.bundleId,
    required this.productId,
    required this.subscriptionGroupIdentifier,
    required this.purchaseDate,
    required this.originalPurchaseDate,
    required this.expiresDate,
    required this.quantity,
    required this.type,
    required this.inAppOwnershipType,
    required this.signedDate,
    required this.environment,
    required this.transactionReason,
    required this.storefront,
    required this.storefrontId,
    required this.price,
    required this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      originalTransactionId: json['originalTransactionId'],
      webOrderLineItemId: json['webOrderLineItemId'],
      bundleId: json['bundleId'],
      productId: json['productId'],
      subscriptionGroupIdentifier: json['subscriptionGroupIdentifier'],
      purchaseDate: json['purchaseDate'],
      originalPurchaseDate: json['originalPurchaseDate'],
      expiresDate: json['expiresDate'],
      quantity: json['quantity'],
      type: json['type'],
      inAppOwnershipType: json['inAppOwnershipType'],
      signedDate: json['signedDate'],
      environment: json['environment'],
      transactionReason: json['transactionReason'],
      storefront: json['storefront'],
      storefrontId: json['storefrontId'],
      price: json['price'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'originalTransactionId': originalTransactionId,
      'webOrderLineItemId': webOrderLineItemId,
      'bundleId': bundleId,
      'productId': productId,
      'subscriptionGroupIdentifier': subscriptionGroupIdentifier,
      'purchaseDate': purchaseDate,
      'originalPurchaseDate': originalPurchaseDate,
      'expiresDate': expiresDate,
      'quantity': quantity,
      'type': type,
      'inAppOwnershipType': inAppOwnershipType,
      'signedDate': signedDate,
      'environment': environment,
      'transactionReason': transactionReason,
      'storefront': storefront,
      'storefrontId': storefrontId,
      'price': price,
      'currency': currency,
    };
  }
}
