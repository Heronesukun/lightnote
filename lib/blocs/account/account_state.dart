import 'package:equatable/equatable.dart';
import '../../../models/account.dart';

enum AccountStatus { initial, loading, loaded, error }

class AccountState extends Equatable {
  final AccountStatus status;
  final List<Account> accounts;
  final String? errorMessage;

  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  AccountState copyWith({
    AccountStatus? status,
    List<Account>? accounts,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  double get totalBalance => accounts.fold(0, (sum, acc) => sum + acc.balance);

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}
