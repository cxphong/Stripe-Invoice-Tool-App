import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'; // Added import for getApplicationDocumentsDirectory
import 'package:stripe_invoice/transaction.dart';

class TransactionDb {
  static final TransactionDb _instance = TransactionDb._internal();
  static Database? _database;

  factory TransactionDb() {
    return _instance;
  }

  TransactionDb._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'transactions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        transactionId TEXT PRIMARY KEY,
        originalTransactionId TEXT,
        webOrderLineItemId TEXT,
        bundleId TEXT,
        productId TEXT,
        subscriptionGroupIdentifier TEXT,
        purchaseDate INTEGER,
        originalPurchaseDate INTEGER,
        expiresDate INTEGER,
        quantity INTEGER,
        type TEXT,
        inAppOwnershipType TEXT,
        signedDate INTEGER,
        environment TEXT,
        transactionReason TEXT,
        storefront TEXT,
        storefrontId TEXT,
        price INTEGER,
        currency TEXT
      )
    ''');
  }

  Future<int> insertTransaction(LastTransaction transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toJson());
  }

  Future<List<LastTransaction>> getTransactions() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return LastTransaction.fromJson(maps[i]);
    });
  }
}

// Assuming you have a Transaction class defined like this: