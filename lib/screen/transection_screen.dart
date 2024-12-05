import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:sms_arjit/model/datamodel.dart';
import 'package:sms_arjit/services/databaseservices.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transactions> transactions = []; // List to hold transactions

  @override
  void initState() {
    super.initState();
    fetchTransactions(); // Fetch transactions when screen is initialized
  }

  /// Fetch transactions from the database
  Future<void> fetchTransactions() async {
    try {
      transactions = await DatabaseService.fetchTransactions(); // Fetch from DB
      setState(() {}); // Refresh UI
    } catch (e) {
      print("Error fetching transactions: $e");
    }
  }

  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.status;
    print("Initial SMS permission status: $status");

    if (status.isDenied || status.isRestricted) {
      print("Requesting SMS permission...");
      status = await Permission.sms.request();
      print("Updated SMS permission status: $status");
    }

    if (status.isPermanentlyDenied) {
      print("Permission permanently denied. Opening settings...");
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  Future<void> readSmsAndSaveTransactions() async {
    if (!await requestSmsPermission()) {
      print("SMS Permission Denied!");
      return; // Exit if permission not granted
    }

    print("SMS Permission Granted. Reading messages...");
    SmsQuery query = SmsQuery();
    List<SmsMessage> messages = await query.getAllSms;

    for (var message in messages) {
      if (isTransactionMessage(message.body)) {
        Transactions? transaction = parseTransaction(message.body);
        if (transaction != null) {
          await DatabaseService.insertTransaction(transaction);
        }
      }
    }
  }

  bool isTransactionMessage(String? messageBody) {
    if (messageBody == null) return false;
    return messageBody.contains('debit') ||
        messageBody.contains('credit') ||
        messageBody.contains('transaction') ||
        messageBody.contains('balance');
  }

  Transactions? parseTransaction(String? messageBody) {
  if (messageBody == null) return null;

  try {
    // Determine the transaction type (Debit or Credit)
    String type = messageBody.contains('debit') || messageBody.contains('debited') || messageBody.contains('spent') ? 'Debit' : 'Credit';
    
    // Extract amount using a regex (handles commas and decimals)
    RegExp amountRegex = RegExp(r'(\d+(,\d{3})*(\.\d{2})?)');
    String amountString = amountRegex.firstMatch(messageBody)?.group(0) ?? '0.0';
    double amount = double.parse(amountString.replaceAll(',', '')); // Remove commas for parsing

    // Extract date using a regex that matches different date formats
    RegExp dateRegex = RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})|([A-Za-z]+[-]?\d{1,2}[-]?\d{2,4})'); 
    String date = dateRegex.firstMatch(messageBody)?.group(0) ?? DateTime.now().toString();

    // Extract bank name (matching common bank names)
    RegExp bankRegex = RegExp(r'(Kotak|ICICI|SBI|HDFC|Axis|PNB|Bank)\s?(\w+)?');
    String bankName = bankRegex.firstMatch(messageBody)?.group(0) ?? 'Unknown Bank';

    // For transactions involving credit card usage (spent), treat as a Debit
    if (messageBody.contains('spent using')) {
      type = 'Debit';  // Treat spending as Debit
    }

    // Create and return a Transactions object with extracted details
    return Transactions(
      type: type,
      amount: amount,
      date: date,
      bankName: bankName,
    );
  } catch (e) {
    print("Error parsing SMS: $e");
    return null;
  }
}


  /// Read SMS and save as transactions
  Future<void> refreshTransactions() async {
    try {
      bool permissionGranted =
          await requestSmsPermission(); // Request SMS permission
      if (!permissionGranted) {
        print("SMS Permission Denied!");
        return;
      }

      await readSmsAndSaveTransactions(); // Read SMS and save transactions to DB
      await fetchTransactions(); // Fetch updated transactions from DB
    } catch (e) {
      print("Error refreshing transactions: $e");
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              bool granted = await requestSmsPermission();
              print(
                  granted ? "SMS Permission Granted" : "SMS Permission Denied");
            },
            child: const Text('Test SMS Permission'),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No Recent Transactions'))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return ListTile(
                        title: Text(
                          '${transaction.type}: \$${transaction.amount.toStringAsFixed(2)}',
                        ),
                        subtitle: Text(
                            '${transaction.date} - ${transaction.bankName}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
