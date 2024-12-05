import 'package:flutter/material.dart';
import 'package:sms_arjit/model/datamodel.dart';


class TransactionListItem extends StatelessWidget {
  final Transactions transaction;

  const TransactionListItem({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(
          transaction.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
          color: transaction.type == 'credit' ? Colors.green : Colors.red,
        ),
        title: Text('${transaction.bankName}'),
        subtitle: Text('Date: ${transaction.date}'),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.type == 'credit' ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
