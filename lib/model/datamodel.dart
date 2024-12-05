class Transactions {
  final int? id; // Nullable for auto-increment
  final String type; // Debit or Credit
  final double amount; // Transaction amount
  final String date; // Transaction date
  final String bankName; // Bank or issuer name

  Transactions({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.bankName,
  });

  // Convert Transaction object to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'bankName': bankName,
    };
  }

  // Convert a Map from SQLite into a Transaction object
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
      bankName: map['bankName'],
    );
  }
}

