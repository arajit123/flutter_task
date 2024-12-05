import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_arjit/model/datamodel.dart';
import 'package:sms_arjit/services/databaseservices.dart';

class SmsReaderService {
  // Request SMS Permission
  Future<bool> requestSmsPermission() async {
    var status = await Permission.sms.status;

    if (status.isDenied) {
      status = await Permission.sms.request();
    }

    return status.isGranted;
  }

  // Read SMS and Save Transactions
  bool isTransactionMessage(String? messageBody) {
    if (messageBody == null) return false;
    return messageBody.contains('debit') ||
        messageBody.contains('credit') ||
        messageBody.contains('transaction') ||
        messageBody.contains('balance');
  }

// Parse transaction SMS to extract details
  Transactions? parseTransaction(String? messageBody) {
    if (messageBody == null) return null;

    try {
      String type = messageBody.contains('debit') ? 'Debit' : 'Credit';
      RegExp amountRegex = RegExp(r'(\d+(,\d{3})*(\.\d{2})?)');
      RegExp dateRegex = RegExp(r'(\d{2}[-/]\d{2}[-/]\d{4})');
      RegExp bankRegex = RegExp(r'from\s(\w+)\s'); // Example: "from HDFC Bank"

      String amount = amountRegex.firstMatch(messageBody)?.group(0) ?? '0.0';
      String date = dateRegex.firstMatch(messageBody)?.group(0) ??
          DateTime.now().toString();
      String bankName =
          bankRegex.firstMatch(messageBody)?.group(1) ?? 'Unknown Bank';

      return Transactions(
        type: type,
        amount: double.parse(amount.replaceAll(',', '')),
        date: date,
        bankName: bankName,
      );
    } catch (e) {
      print("Error parsing SMS: $e");
      return null;
    }
  }

// Read SMS and save transaction data to the database
  Future<void> readSmsAndSaveTransactions() async {
    if (!await requestSmsPermission()) {
      print("SMS Permission Denied!");
      return;
    }

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
}
