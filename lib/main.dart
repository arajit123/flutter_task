import 'package:flutter/material.dart';
import 'package:sms_arjit/screen/transection_screen.dart';
import 'package:sms_arjit/screen/transection_summary_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transaction Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the Transactions Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                );
              },
              child: const Text('View Transactions'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Transaction Summary Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionSummaryScreen(),
                  ),
                );
              },
              child: const Text('View Summary'),
            ),
          ],
        ),
      ),
    );
  }
}
