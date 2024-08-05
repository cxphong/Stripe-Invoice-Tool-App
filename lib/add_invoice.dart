import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/customer.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';
import 'package:stripe_invoice/taxrate.dart';
import 'package:stripe_invoice/data.dart';

class Item {
  String name;
  double amount;
  int quantity;
  TaxRate? taxRate;

  Item({
    required this.name,
    required this.amount,
    required this.quantity,
    required this.taxRate
  });
}

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({Key? key}) : super(key: key);

  @override
  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  Customer? selectedCustomer;
  Currency? selectedCurrency;
  int selectedDate = -1;
  SharedData sharedData = SharedData();

  final List<String> dueDaysOptions = [
    'Today',
    'Tomorrow',
    '7 Days',
    '14 Days',
    '30 Days',
    '45 Days',
    '60 Days',
    '90 Days',
  ];
  late String selectedDueDay;
  final List<Item> items = [];
  final TextEditingController memoController = TextEditingController();
  TaxRate? selectedInvoiceTaxRate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDueDay = dueDaysOptions.first;
  }

  void addItem() {
    setState(() {
      items.add(Item(name: '', amount: 0.0, quantity: 1, taxRate: null));
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final DateTime pickedDateMidnight =
          DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      final difference = pickedDateMidnight.difference(today);
      print(difference.inDays);

      if (difference.inDays == 0) {
        setState(() {
          selectedDueDay = "Today";
        });
      } else if (difference.inDays == 1) {
        setState(() {
          selectedDueDay = "Tomorrow";
        });
      } else {
        setState(() {
          selectedDate = difference.inDays;
        });
      }
    }
  }

  Future<void> createInvoice() async {
    if (selectedCustomer == null ||
        selectedDueDay == null ||
        items.isEmpty ||
        selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    final dueDaysMap = {
      'Today': 0,
      'Tomorrow': 1,
      '7 Days': 7,
      '14 Days': 14,
      '30 Days': 30,
      '45 Days': 45,
      '60 Days': 60,
      '90 Days': 90,
    };

    final dueDate =
        DateTime.now().add(Duration(days: dueDaysMap[selectedDueDay]!));

    // Step 1: Create Invoice
    final invoiceResponse = await http.post(
      Uri.https('api.stripe.com', '/v1/invoices'),
      headers: {
        'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'customer': selectedCustomer!.id,
        'description': memoController.text,
        'currency': selectedCurrency!.code,
        'due_date': (dueDate.millisecondsSinceEpoch / 1000)
            .round()
            .toString(), // Unix timestamp in seconds
        'collection_method': 'send_invoice',
        'pending_invoice_items_behavior': 'exclude',
        if (selectedInvoiceTaxRate != null)
          'default_tax_rates[]': selectedInvoiceTaxRate!.id,
      },
    );

    print(invoiceResponse.body);
    if (invoiceResponse.statusCode != 200) {
      print(invoiceResponse.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to create invoice: ${invoiceResponse.statusCode}')),
      );
      return;
    }

    final invoiceData = jsonDecode(invoiceResponse.body);
    final String invoiceId = invoiceData['id'];

    // Step 2: Create Invoice Items
    for (var item in items) {
      final response = await http.post(
        Uri.https('api.stripe.com', '/v1/invoiceitems'),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': selectedCustomer!.id,
          'unit_amount':
              (item.amount * 100).toInt().toString(), // Amount in cents
          'currency': selectedCurrency!.code,
          'description': item.name,
          'quantity': item.quantity.toString(),
          'invoice': invoiceId,
          if (item.taxRate != null)
            'tax_rates[]': item.taxRate!.id,
        },
      );

      if (response.statusCode != 200) {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to create invoice item: ${response.statusCode}')),
        );
        return;
      }
    }

    // Step 3: Finalize Invoice
    final finalizeResponse = await http.post(
      Uri.https('api.stripe.com', '/v1/invoices/$invoiceId/finalize'),
      headers: {
        'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (finalizeResponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invoice created and finalized successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to finalize invoice: ${finalizeResponse.statusCode}')),
      );
    }
  }

  Future<void> _selectTaxRate(Item item, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaxRateScreen(selectMode: true)),
    );
    if (result != null && result is TaxRate) {
      setState(() {
        items[index].taxRate = result;
      });
    }
  }

  Future<void> _selectTaxRateForInvoice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaxRateScreen(selectMode: true)),
    );
    if (result != null && result is TaxRate) {
      setState(() {
        selectedInvoiceTaxRate = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Invoice'),
        backgroundColor: Color(0xFF29B6F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Theme.of(context).brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300) // Light theme border
                      : Border.all(), // Dark theme border
                ),
                child: ListTile(
                  title: const Text('Select Customer'),
                  subtitle: Text(selectedCustomer != null
                      ? selectedCustomer!.name
                      : 'No customer selected'),
                  onTap: () async {
                    final result = await Navigator.push<Customer>(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CustomerScreen(isFromAddInvoice: true)),
                    );
                    if (result != null) {
                      setState(() {
                        selectedCustomer = result;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Theme.of(context).brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300) // Light theme border
                      : Border.all(), // Dark theme border
                ),
                child: TextButton.icon(
                  onPressed: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showSearchField: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (Currency currency) {
                        setState(() {
                          selectedCurrency = currency;
                        });
                      },
                    );
                  },
                  icon: Icon(Icons.arrow_drop_down),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // Aligns the icon and text to the left
                    children: [
                      Text(
                        selectedCurrency != null
                            ? selectedCurrency!.name +
                                " - " +
                                selectedCurrency!.code
                            : "Select currency",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Item Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ...items.map((item) {
                int index = items.indexOf(item);
                return Column(
                  key: ValueKey(item),
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        // filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      onChanged: (value) {
                        setState(() {
                          item.name = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Amount in ${selectedCurrency?.code ?? ''}',
                        // filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          item.amount = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        // filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          item.quantity = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    ListTile(
                      title: Text('Select Tax Rate'),
                      subtitle: Text(item.taxRate != null
                          ? '${item.taxRate!.displayName} - ${item.taxRate!.percentage}%'
                          : 'None'),
                      trailing: Icon(Icons.arrow_drop_down),
                      onTap: () => _selectTaxRate(item, index),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeItem(index),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
              Container(
                decoration: BoxDecoration(
                  border: Theme.of(context).brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300) // Light theme border
                      : Border.all(), // Dark theme border
                ),
                child: TextButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                  decoration: BoxDecoration(
                    border: Theme.of(context).brightness == Brightness.light
                        ? Border.all(color: Colors.grey.shade300) // Light theme border
                        : Border.all(), // Dark theme border
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedDueDay,
                      decoration: const InputDecoration(labelText: 'Due Days'),
                      items: [
                        ...dueDaysOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }),
                        // DropdownMenuItem(
                        //   value: 'Other',
                        //   child: Text('Other'),
                        // ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          // if (newValue == 'Other') {
                          //   _selectDate();
                          // } else {
                            selectedDueDay = newValue!;
                            // selectedDate = -1;
                          // }
                        });
                      },
                    ),
                  )),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Theme.of(context).brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300) // Light theme border
                      : Border.all(), // Dark theme border
                ),
                child: ListTile(
                  title: const Text('Select Tax Rate for Invoice'),
                  subtitle: Text(selectedInvoiceTaxRate != null
                      ? '${selectedInvoiceTaxRate!.displayName} - ${selectedInvoiceTaxRate!.percentage}%'
                      : 'None'),
                  trailing: Icon(Icons.arrow_drop_down),
                  onTap: _selectTaxRateForInvoice,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Theme.of(context).brightness == Brightness.light
                      ? Border.all(color: Colors.grey.shade300) // Light theme border
                      : Border.all(), // Dark theme border
                ),
                child: TextField(
                  controller: memoController,
                  decoration: InputDecoration(
                    labelText: 'Memo',
                    // filled: true,
                    border: InputBorder.none
                    // fillColor: Colors.grey[200],
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: createInvoice,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Color(0xFF29B6F6),
                  // Background color of the button
                  // foregroundColor: Colors.white,
                  // Text color of the button
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Button border radius
                  ),
                  elevation: 3, // Elevation of the button
                ),
                child: Text(
                  'Add Invoice',
                  style: TextStyle(
                    fontSize: 16.0, // Font size of the button text
                    fontWeight:
                        FontWeight.bold, // Font weight of the button text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
