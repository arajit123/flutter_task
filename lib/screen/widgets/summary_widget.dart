import 'package:flutter/material.dart';
import 'package:sms_arjit/model/datamodel.dart';


class SummaryWidget extends StatelessWidget {
  final List<Transactions> transactions;

  const SummaryWidget({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalCredits = transactions
        .where((transaction) => transaction.type == 'credit')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    double totalDebits = transactions
        .where((transaction) => transaction.type == 'debit')
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Text('Total Credits'),
              trailing: Text(
                '\$${totalCredits.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              title: Text('Total Debits'),
              trailing: Text(
                '\$${totalDebits.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
