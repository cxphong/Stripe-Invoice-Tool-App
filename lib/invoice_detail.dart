import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/custom_appbar.dart';
import 'package:stripe_invoice/invoice.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:stripe_invoice/utils.dart';
import 'package:stripe_invoice/data.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  final SharedData sharedData = SharedData();

  InvoiceDetailScreen({Key? key, required this.invoice})
      : super(key: key);

  void showProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog();
      },
    );
  }

  void hideProgress(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> sharePdfFromUrl(String pdfUrl, String filename) async {
    try {
      // Download the PDF from the URL
      var response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;

        // Share the downloaded PDF
        await Printing.sharePdf(
          bytes: bytes,
          filename: filename,
        );
      } else {
        // Handle error if PDF download fails
        print('Failed to download PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions that occur during the process
      print('Error sharing PDF: $e');
    }
  }

  void generateAndPrintInvoice(Invoice invoice, BuildContext context) async {
    showProgress(context);

    await sharePdfFromUrl(invoice.invoicePdf!, 'Invoice_${invoice.number}.pdf');
    hideProgress(context);
  }

  Future<http.Response?> deleteDraftInvoice(String invoiceId) async {
    final url = 'https://api.stripe.com/v1/invoices/$invoiceId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        },
      );

      return response;
    } catch (e) {
      print('Error deleting invoice: $e');
      rethrow;
    }
  }

  Future<http.Response?> finalizeInvoice(String invoiceId) async {
    final url = 'https://api.stripe.com/v1/invoices/$invoiceId/finalize';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        },
      );
      return response;
    } catch (e) {
      print('Error finalizing invoice: $e');
      rethrow;
    }
  }

  Future<http.Response?> voidInvoice(String invoiceId) async {
    final url = 'https://api.stripe.com/v1/invoices/$invoiceId/void';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        },
      );

      return response;
    } catch (e) {
      print('Error voiding invoice: $e');
      rethrow;
    }
  }

  Future<http.Response?> markUncollectibleInvoice(String invoiceId) async {
    final url =
        'https://api.stripe.com/v1/invoices/$invoiceId/mark_uncollectible';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        },
      );
      return response;
    } catch (e) {
      print('Error marking invoice as uncollectible: $e');
      rethrow;
    }
  }

  Future<http.Response?> sendInvoice(String invoiceId) async {
    final url = 'https://api.stripe.com/v1/invoices/$invoiceId/send';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        },
      );
      return response;
    } catch (e) {
      print('Error sending invoice: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: const Text('Invoice Details', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist',)),
        // foregroundColor: Colors.white,
        backgroundColor: Color(0xFF29B6F6),
      ),
      body: Container(
        // color: Colors.grey.shade200,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            _buildDetailSection(context),
            SizedBox(height: 20),
            if (invoice.lineItems.isNotEmpty) _buildLineItemsSection(context),
            SizedBox(height: 20),
            if (invoice.status != 'void') _buildActionSection(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Theme.of(context).brightness == Brightness.light
            ? Border.all(color: Colors.grey.shade300) // Light theme border
            : Border.all(), // Dark theme border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Description',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Qty',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Unit price',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Amount',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              ...invoice.lineItems.map<TableRow>((line) {
                return TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        decodeText(line.description != null ? line.description! : "",),
                        style: TextStyle(fontFamily: 'Urbanist'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(line.quantity.toString(), style: TextStyle(fontFamily: 'Urbanist')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(line.unitPrice.toStringAsFixed(2), style: TextStyle(fontFamily: 'Urbanist')),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(line.amount.toStringAsFixed(2), style: TextStyle(fontFamily: 'Urbanist')),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Theme.of(context).brightness == Brightness.light
            ? Border.all(color: Colors.grey.shade300) // Light theme border
            : Border.all(), // Dark theme border
      ),
      child: Column(
        children: [
          _buildDetailRow('Customer Name', invoice.customerName),
          _buildDetailRow('Status', invoice.status),
          _buildDetailRow('Amount Due',
              '${invoice.currency.toUpperCase()} \$${invoice.amountDue.toStringAsFixed(2)}'),
          _buildDetailRow('Due Date', _formatDate(invoice.periodEnd)),
          if (invoice.hostedInvoiceUrl != null)
            _buildDetailRowWithCopyIcon(
                'Invoice URL', invoice.hostedInvoiceUrl!),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Theme.of(context).brightness == Brightness.light
              ? Border.all(color: Colors.grey.shade300) // Light theme border
              : Border.all(), // Dark theme border
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
          ),
          _buildActionsBasedOnStatus(context, invoice),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(title ,style: TextStyle(fontFamily: 'Urbanist'),),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                  style: TextStyle(fontFamily: 'Urbanist')
                // style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              // Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
        if (title != 'Due Date' ||
            (title == 'Due Date' && invoice.hostedInvoiceUrl != null))
          // Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          Divider()
      ],
    );
  }

  Widget _buildDetailRowWithCopyIcon(String title, String url) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontFamily: 'Urbanist'),),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.copy, size: 16, color: Color(0xFF29B6F6)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Copied to clipboard')),
                  // );
                },
              ),
              // Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
        // Divider(height: 1, thickness: 1, color: Colors.grey[200]),
      ],
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String actionTitle,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          // backgroundColor: Colors.white,
          title: Text(title, style: TextStyle(fontFamily: 'Urbanist')),
          content: Text(description, style: TextStyle(fontFamily: 'Urbanist')),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style:
                    TextStyle(fontFamily: 'Urbanist', color: Color(0xFF29B6F6), fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(actionTitle,
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onDelete(); // Call the delete callback
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionsBasedOnStatus(BuildContext context, Invoice invoice) {
    var status = invoice.status;

    List<Widget> actions = [];

    if (status == 'draft') {
      actions.addAll([
        _buildActionListItem(context, 'Delete Invoice', false, invoice),
        _buildActionListItem(context, 'Finalize Invoice', invoice.invoicePdf == null, invoice),
      ]);
    } else if (status == 'open') {
      actions.addAll([
        _buildActionListItem(context, 'Pay Invoice', false, invoice),
        _buildActionListItem(context, 'Send Reminder Email', false, invoice),
        _buildActionListItem(
            context, 'Mark Uncollectible Invoice', false, invoice),
        _buildActionListItem(context, 'Cancel Invoice', invoice.invoicePdf == null, invoice),
      ]);
    } else if (status == 'uncollectible') {
      actions.addAll([
        _buildActionListItem(context, 'Cancel Invoice', false, invoice),
        _buildActionListItem(context, 'Pay Invoice', invoice.invoicePdf == null, invoice),
      ]);
    }

    if (invoice.invoicePdf != null) {
      actions.addAll([
        _buildActionListItem(context, 'Download Invoice PDF', true, invoice),
        // _buildActionListItem(context, 'Download Receipt PDF', () {
        //   // Add your action here
        // }, true, invoice),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions,
    );
  }

  Widget _buildActionListItem(
      BuildContext context, String text, bool isLastItem, Invoice invoice) {
    return Material(
      // color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Navigate to the pay invoice screen when "Pay Invoice" is clicked
          if (text == 'Pay Invoice') {
            _launchInvoiceURL(invoice.hostedInvoiceUrl!);
          } else if (text == "Cancel Invoice") {
            _showConfirmDialog(context,
                title: 'Confirm',
                description: 'Are you sure you want to cancel this invoice?',
                actionTitle: "Cancel Invoice", onDelete: () async {
              try {
                final response = await voidInvoice(invoice.id);
                if (response != null && response?.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Canceled invoice succeeded", style: TextStyle(fontFamily: 'Urbanist'))));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(response!.body, style: TextStyle(fontFamily: 'Urbanist'))));
                }
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Urbanist'))));
              }
            });
          } else if (text == "Mark Uncollectible Invoice") {
            _showConfirmDialog(context,
                title: 'Confirm',
                description:
                    "Are you sure you want to mark this invoice as uncollectible?",
                actionTitle: "Mark Uncollectible", onDelete: () async {
              try {
                final response = await markUncollectibleInvoice(invoice.id);
                if (response != null && response?.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Marked the invoice as uncollectible succeeded",
                          style: TextStyle(fontFamily: 'Urbanist'))));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(response!.body, style: TextStyle(fontFamily: 'Urbanist'))));
                }
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Urbanist'))));
              }
            });
          } else if (text == "Finalize Invoice") {
            _showConfirmDialog(context,
                title: 'Confirm',
                description:
                    'To finalize an invoice is to transition it to an \'open\' state, allowing the customer to proceed with payment.',
                actionTitle: "Finalize Invoice", onDelete: () async {
              try {
                final response = await finalizeInvoice(invoice.id);
                if (response != null && response?.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Finalized  invoice succeeded", style: TextStyle(fontFamily: 'Urbanist'))));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(jsonDecode(response!.body, ), style: TextStyle(fontFamily: 'Urbanist'))));
                }
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Urbanist'))));
              }
            });
          } else if (text == "Delete Invoice") {
            _showConfirmDialog(
              context,
              title: 'Confirm',
              description: 'Are you sure you want to delete this invoice?',
              actionTitle: "Delete Invoice",
              onDelete: () async {
                // Define your delete action here
                try {
                  final response = await deleteDraftInvoice(invoice.id);
                  if (response != null && response?.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Delete  invoice succeeded", style: TextStyle(fontFamily: 'Urbanist'))));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(response!.body, style: TextStyle(fontFamily: 'Urbanist'))));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Urbanist'))));
                }
              },
            );
          } else if (text == "Download Invoice PDF") {
            generateAndPrintInvoice(invoice, context);
          } else if (text == "Send Reminder Email") {
            try {
              final response = await sendInvoice(invoice.id);
              if (response != null && response?.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Send invoice succeeded", style: TextStyle(fontFamily: 'Urbanist'))));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(response!.body, style: TextStyle(fontFamily: 'Urbanist'))));
              }
            } catch (e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString(), style: TextStyle(fontFamily: 'Urbanist'))));
            }
          }
        },
        child: Column(
          children: [
            ListTile(
              title: Text(text, style: TextStyle(fontFamily: 'Urbanist', color: Color(0xFF29B6F6))),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
            if (!isLastItem)
              Divider(),
          ],
        ),
      ),
    );
  }

  Future<void> _launchInvoiceURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
