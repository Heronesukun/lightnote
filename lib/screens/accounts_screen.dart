import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/account/account_event.dart';
import '../blocs/account/account_state.dart';
import '../models/account.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账户'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state.status == AccountStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.accounts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无账户', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final account = state.accounts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(account.color).withValues(alpha: 0.2),
                    child: Icon(
                      _getAccountIcon(account.type),
                      color: Color(account.color),
                    ),
                  ),
                  title: Text(account.name),
                  subtitle: Text(_getAccountTypeName(account.type)),
                  trailing: Text(
                    currencyFormat.format(account.balance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: account.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  onTap: () => _showEditAccountDialog(context, account),
                  onLongPress: () => _showDeleteDialog(context, account),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet;
      case AccountType.alipay:
        return Icons.payment;
      case AccountType.wechat:
        return Icons.chat;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.other:
        return Icons.more_horiz;
    }
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '现金';
      case AccountType.alipay:
        return '支付宝';
      case AccountType.wechat:
        return '微信';
      case AccountType.bank:
        return '银行卡';
      case AccountType.creditCard:
        return '信用卡';
      case AccountType.other:
        return '其他';
    }
  }

  void _showAddAccountDialog(BuildContext context) {
    _showAccountDialog(context, null);
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    _showAccountDialog(context, account);
  }

  void _showAccountDialog(BuildContext context, Account? account) {
    final nameController = TextEditingController(text: account?.name ?? '');
    AccountType selectedType = account?.type ?? AccountType.cash;
    int selectedColor = account?.color ?? 0xFF6BCB77;

    final colors = [
      0xFF6BCB77, 0xFF1677FF, 0xFF07C160, 0xFFFF6B6B,
      0xFFFFE66D, 0xFF95E1D3, 0xFFAA96DA, 0xFFFCBAD3,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(account == null ? '添加账户' : '编辑账户'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '账户名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('账户类型', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AccountType.values.map((type) {
                    return ChoiceChip(
                      label: Text(_getAccountTypeName(type)),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('颜色', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                
                final newAccount = Account(
                  id: account?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  type: selectedType,
                  balance: account?.balance ?? 0,
                  icon: _getAccountIcon(selectedType).codePoint.toString(),
                  color: selectedColor,
                  createdAt: account?.createdAt ?? DateTime.now(),
                );

                if (account == null) {
                  context.read<AccountBloc>().add(AddAccount(newAccount));
                } else {
                  context.read<AccountBloc>().add(UpdateAccount(newAccount));
                }
                
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除账户'),
        content: Text('确定要删除账户 "${account.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountBloc>().add(DeleteAccount(account.id));
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
