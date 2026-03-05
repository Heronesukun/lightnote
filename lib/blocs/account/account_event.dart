import 'package:equatable/equatable.dart';
import '../../../models/account.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final Account account;

  const AddAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final String id;

  const DeleteAccount(this.id);

  @override
  List<Object?> get props => [id];
}
