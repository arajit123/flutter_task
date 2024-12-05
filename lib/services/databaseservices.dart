import 'package:path/path.dart'; // For working with file paths
import 'package:sms_arjit/model/datamodel.dart';
import 'package:sqflite/sqflite.dart'; // For SQLite database// Import your transaction model

class DatabaseService {
  // Initialize the database
  static Future<Database> initializeDB() async {
    // Get the default database path
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'transactions.db');

    // Open the database
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the transactions table
        await db.execute(
          '''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            bankName TEXT NOT NULL
          )
          ''',
        );
      },
    );
  }

  // Insert a transaction into the database
  static Future<void> insertTransaction(Transactions transaction) async {
    final db = await initializeDB();
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace in case of conflict
    );
  }

  // Fetch all transactions from the database
  static Future<List<Transactions>> fetchTransactions() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('transactions');
    return queryResult.map((e) => Transactions.fromMap(e)).toList();
  }

  // Delete all transactions (optional for resetting the database)
  static Future<void> deleteAllTransactions() async {
    final db = await initializeDB();
    await db.delete('transactions');
  }

  // Delete a specific transaction by ID
  static Future<void> deleteTransaction(int id) async {
    final db = await initializeDB();
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
   static Future<Map<String, double>> fetchTransactionSummary() async {
    List<Transactions> transactions = await fetchTransactions();

    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (var transaction in transactions) {
      if (transaction.type == 'Debit') {
        totalDebit += transaction.amount;
      } else if (transaction.type == 'Credit') {
        totalCredit += transaction.amount;
      }
    }

    return {
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
    };
  }
}

