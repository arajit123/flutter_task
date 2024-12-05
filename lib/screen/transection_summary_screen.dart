import 'package:flutter/material.dart';

import 'package:sms_arjit/services/databaseservices.dart';

class TransactionSummaryScreen extends StatefulWidget {
  const TransactionSummaryScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransactionSummaryScreenState createState() =>
      _TransactionSummaryScreenState();
}

class _TransactionSummaryScreenState extends State<TransactionSummaryScreen> {
  late Future<Map<String, double>> summaryFuture;

  @override
  void initState() {
    super.initState();
    summaryFuture = DatabaseService.fetchTransactionSummary(); // Fetch the summary of transactions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Summary'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          } else {
            // Get the totals for credit and debit
            double totalDebit = snapshot.data!['totalDebit'] ?? 0.0;
            double totalCredit = snapshot.data!['totalCredit'] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Debit: ₹${totalDebit.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total Credit: ₹${totalCredit.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
