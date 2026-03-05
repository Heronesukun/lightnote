import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final String? merchant;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.merchant,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? merchant,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': type == TransactionType.expense ? -amount.abs() : amount.abs(),
      'type': type.name,
      'category_id': categoryId,
      'account_id': accountId,
      'merchant': merchant,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: (map['amount'] as num).abs().toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      categoryId: map['category_id'] as String,
      accountId: map['account_id'] as String,
      merchant: map['merchant'] as String?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, amount, type, categoryId, accountId, merchant, note, date, createdAt, updatedAt];
}
