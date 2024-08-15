import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_invoice/renewal_transaction.dart';
import 'package:intl/intl.dart';

class RenewalTransactionScreen extends StatelessWidget {
  final RenewalTransaction? transaction;

  const RenewalTransactionScreen({Key? key, required this.transaction}) : super(key: key);

  String _formatDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MM-dd-yyyy h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Status'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   title: const Text('Expiration Intent'),
          //   subtitle: Text(transaction!.expirationIntent.toString()),
          // ),
          // ListTile(
          //   title: const Text('Original Transaction ID'),
          //   subtitle: Text(transaction!.originalTransactionId),
          // ),
          // ListTile(
          //   title: const Text('Auto Renew Product ID'),
          //   subtitle: Text(transaction!.autoRenewProductId),
          // ),
          ListTile(
            title: const Text('Product ID'),
            subtitle: Text(transaction?.productId ?? ''),
          ),
          ListTile(
            title: const Text('Auto Renew Status'),
            subtitle: Text(transaction?.autoRenewStatus == 0 ? "NO" : "YES"),
          ),
          // ListTile(
          //   title: const Text('Is in Billing Retry Period'),
          //   subtitle: Text(transaction!.isInBillingRetryPeriod.toString()),
          // ),
          // ListTile(
          //   title: const Text('Signed Date'),
          //   subtitle: Text(_formatDate(transaction!.signedDate)),
          // ),
          // ListTile(
          //   title: const Text('Environment'),
          //   subtitle: Text(transaction!.environment),
          // ),
          ListTile(
            title: const Text('Recent Subscription Start Date'),
            subtitle: Text(_formatDate(transaction?.recentSubscriptionStartDate ?? 0)),
          ),
          ListTile(
            title: const Text('Renewal Date'),
            subtitle: Text(_formatDate(transaction?.renewalDate ?? 0)),
          ),
        ],
      ),
    );
  }
}
