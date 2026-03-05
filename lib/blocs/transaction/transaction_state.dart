import 'package:equatable/equatable.dart';
import '../../../models/transaction.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<Transaction> transactions;
  final DateTime selectedMonth;
  final double totalIncome;
  final double totalExpense;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    required this.selectedMonth,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    DateTime? selectedMonth,
    double? totalIncome,
    double? totalExpense,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, selectedMonth, totalIncome, totalExpense, errorMessage];
}
