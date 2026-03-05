import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/database_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final DatabaseRepository repository;

  AccountBloc(this.repository) : super(const AccountState()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.loading));
    try {
      final accounts = await repository.getAccounts();
      emit(state.copyWith(
        status: AccountStatus.loaded,
        accounts: accounts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await repository.insertAccount(event.account);
      add(LoadAccounts());
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await repository.updateAccount(event.account);
      add(LoadAccounts());
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await repository.deleteAccount(event.id);
      add(LoadAccounts());
    } catch (e) {
      emit(state.copyWith(
        status: AccountStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
