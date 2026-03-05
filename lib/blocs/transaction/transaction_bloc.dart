import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/database_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final DatabaseRepository repository;

  TransactionBloc(this.repository) : super(TransactionState(selectedMonth: DateTime.now())) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<ChangeMonth>(_onChangeMonth);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final month = event.month ?? state.selectedMonth;
      final transactions = await repository.getTransactions(month: month);
      final stats = await repository.getMonthlyStats(month.year, month.month);
      
      emit(state.copyWith(
        status: TransactionStatus.loaded,
        transactions: transactions,
        selectedMonth: month,
        totalIncome: stats['income'] ?? 0,
        totalExpense: stats['expense'] ?? 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.insertTransaction(event.transaction);
      add(LoadTransactions(month: state.selectedMonth));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.updateTransaction(event.transaction);
      add(LoadTransactions(month: state.selectedMonth));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await repository.deleteTransaction(event.id);
      add(LoadTransactions(month: state.selectedMonth));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTransactions(month: event.month));
  }
}
