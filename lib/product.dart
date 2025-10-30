import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String name;

  Product({
    required this.id,
    required this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.https('api.stripe.com', '/v1/products'),
      headers: {
        'Authorization': ''
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> productsData = jsonData['data'];
      setState(() {
        _products = productsData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      print('Failed to fetch products: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Color(0xFF5469d4),
      ),
      body: _products == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16,),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
