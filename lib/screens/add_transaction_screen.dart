import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/account/account_state.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTransaction,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型切换
            _buildTypeSelector(),
            const SizedBox(height: 24),
            
            // 金额输入
            _buildAmountInput(),
            const SizedBox(height: 24),
            
            // 分类选择
            _buildCategorySelector(),
            const SizedBox(height: 16),
            
            // 账户选择
            _buildAccountSelector(),
            const SizedBox(height: 16),
            
            // 日期选择
            _buildDateSelector(),
            const SizedBox(height: 16),
            
            // 备注
            _buildNoteInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: '支出',
            icon: Icons.arrow_upward,
            color: Colors.red,
            isSelected: _type == TransactionType.expense,
            onTap: () => setState(() => _type = TransactionType.expense),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TypeButton(
            label: '收入',
            icon: Icons.arrow_downward,
            color: Colors.green,
            isSelected: _type == TransactionType.income,
            onTap: () => setState(() => _type = TransactionType.income),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        prefixText: '¥ ',
        prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        hintText: '0.00',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        final categories = state.categories
            .where((c) => c.type == _type)
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategoryId == category.id;
                return ChoiceChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? category.id : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSelector() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('账户', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.accounts.map((account) {
                final isSelected = _selectedAccountId == account.id;
                return ChoiceChip(
                  label: Text(account.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAccountId = selected ? account.id : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: const Text('日期'),
      subtitle: Text(DateFormat('yyyy年MM月dd日').format(_selectedDate)),
      onTap: () async {
        final result = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (result != null) {
          setState(() => _selectedDate = result);
        }
      },
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '备注 (可选)',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // 验证
    if (_amountController.text.isEmpty) {
      _showSnackBar('请输入金额');
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('请输入有效金额');
      return;
    }
    
    if (_selectedCategoryId == null) {
      _showSnackBar('请选择分类');
      return;
    }
    
    if (_selectedAccountId == null) {
      _showSnackBar('请选择账户');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: _selectedDate,
        createdAt: now,
        updatedAt: now,
      );

      context.read<TransactionBloc>().add(AddTransaction(transaction));
      
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('记账成功', isSuccess: true);
      }
    } catch (e) {
      _showSnackBar('记账失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
