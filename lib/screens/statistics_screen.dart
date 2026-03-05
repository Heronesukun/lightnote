import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = state.transactions;
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无数据', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 收支概览
                _buildOverviewCard(context, state),
                const SizedBox(height: 24),
                
                // 支出饼图
                _buildPieChart(context, transactions, TransactionType.expense),
                const SizedBox(height: 24),
                
                // 收入饼图
                _buildPieChart(context, transactions, TransactionType.income),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, TransactionState state) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final balance = state.totalIncome - state.totalExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              DateFormat('yyyy年MM月').format(state.selectedMonth),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('收入', currencyFormat.format(state.totalIncome), Colors.green),
                _buildStatColumn('支出', currencyFormat.format(state.totalExpense), Colors.red),
                _buildStatColumn('结余', currencyFormat.format(balance), 
                    balance >= 0 ? Colors.blue : Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, List<Transaction> transactions, TransactionType type) {
    final filteredTransactions = transactions.where((t) => t.type == type).toList();
    if (filteredTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // 按分类汇总
    final Map<String, double> categoryTotals = {};
    for (var t in filteredTransactions) {
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final sections = <PieChartSectionData>[];
        final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
        
        categoryTotals.forEach((categoryId, amount) {
          final category = categoryState.categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => Category(
              id: categoryId,
              name: '未知',
              type: type,
              icon: 'help',
              color: Colors.grey.value,
              isDefault: false,
            ),
          );
          
          final percentage = (amount / total * 100);
          sections.add(
            PieChartSectionData(
              color: Color(category.color),
              value: amount,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        });

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type == TransactionType.expense ? '支出分布' : '收入分布',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 图例
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: categoryTotals.entries.map((entry) {
                    final category = categoryState.categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => Category(
                        id: entry.key,
                        name: '未知',
                        type: type,
                        icon: 'help',
                        color: Colors.grey.value,
                        isDefault: false,
                      ),
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(category.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(category.name, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
