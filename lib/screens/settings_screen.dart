import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';
import '../blocs/category/category_state.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection(
            '分类管理',
            [
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('支出分类'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCategoryManager(context, TransactionType.expense),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('收入分类'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCategoryManager(context, TransactionType.income),
              ),
            ],
          ),
          _buildSection(
            '数据',
            [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('导出数据'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDialog(context),
              ),
            ],
          ),
          _buildSection(
            '关于',
            [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('版本'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub'),
                onTap: () {
                  // TODO: 打开 GitHub
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showCategoryManager(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryManagerScreen(type: type),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('数据导出功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }
}

class CategoryManagerScreen extends StatelessWidget {
  final TransactionType type;

  const CategoryManagerScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type == TransactionType.expense ? '支出分类' : '收入分类'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          final categories = state.categories.where((c) => c.type == type).toList();
          
          if (categories.isEmpty) {
            return const Center(
              child: Text('暂无分类', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category.color).withValues(alpha: 0.2),
                  child: Icon(Icons.category, color: Color(category.color)),
                ),
                title: Text(category.name),
                subtitle: category.isDefault ? const Text('默认分类') : null,
                trailing: category.isDefault 
                    ? null 
                    : IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(context, category),
                      ),
                onTap: () => _showEditCategoryDialog(context, category),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null, type);
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category, type);
  }

  void _showCategoryDialog(BuildContext context, Category? category, TransactionType type) {
    final nameController = TextEditingController(text: category?.name ?? '');
    int selectedColor = category?.color ?? 0xFF6BCB77;

    final colors = [
      0xFFFF6B6B, 0xFF4ECDC4, 0xFFFFE66D, 0xFF95E1D3,
      0xFFF38181, 0xFFAA96DA, 0xFFFCBAD3, 0xFFA8D8EA,
      0xFF6BCB77, 0xFF4D96FF,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? '添加分类' : '编辑分类'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '分类名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('颜色', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                
                final newCategory = Category(
                  id: category?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  type: type,
                  icon: 'category',
                  color: selectedColor,
                  isDefault: false,
                );

                if (category == null) {
                  context.read<CategoryBloc>().add(AddCategory(newCategory));
                } else {
                  context.read<CategoryBloc>().add(UpdateCategory(newCategory));
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

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除分类 "${category.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(category.id));
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
