import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/account.dart';
import '../models/category.dart';

class DatabaseRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'lightnote.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建账户表
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建交易表
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        merchant TEXT,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // 插入默认分类
    await _insertDefaultCategories(db);
    
    // 插入默认账户
    await _insertDefaultAccounts(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // 支出分类
      {'id': 'cat_food', 'name': '餐饮', 'type': 'expense', 'icon': 'restaurant', 'color': 0xFFFF6B6B, 'is_default': 1},
      {'id': 'cat_transport', 'name': '交通', 'type': 'expense', 'icon': 'directions_car', 'color': 0xFF4ECDC4, 'is_default': 1},
      {'id': 'cat_shopping', 'name': '购物', 'type': 'expense', 'icon': 'shopping_bag', 'color': 0xFFFFE66D, 'is_default': 1},
      {'id': 'cat_entertainment', 'name': '娱乐', 'type': 'expense', 'icon': 'movie', 'color': 0xFF95E1D3, 'is_default': 1},
      {'id': 'cat_housing', 'name': '住房', 'type': 'expense', 'icon': 'home', 'color': 0xFFF38181, 'is_default': 1},
      {'id': 'cat_medical', 'name': '医疗', 'type': 'expense', 'icon': 'local_hospital', 'color': 0xFFAA96DA, 'is_default': 1},
      {'id': 'cat_education', 'name': '教育', 'type': 'expense', 'icon': 'school', 'color': 0xFFFCBAD3, 'is_default': 1},
      {'id': 'cat_other_expense', 'name': '其他', 'type': 'expense', 'icon': 'more_horiz', 'color': 0xFFA8D8EA, 'is_default': 1},
      // 收入分类
      {'id': 'cat_salary', 'name': '工资', 'type': 'income', 'icon': 'account_balance_wallet', 'color': 0xFF6BCB77, 'is_default': 1},
      {'id': 'cat_bonus', 'name': '奖金', 'type': 'income', 'icon': 'card_giftcard', 'color': 0xFF4D96FF, 'is_default': 1},
      {'id': 'cat_investment', 'name': '投资', 'type': 'income', 'icon': 'trending_up', 'color': 0xFF6BCB77, 'is_default': 1},
      {'id': 'cat_other_income', 'name': '其他', 'type': 'income', 'icon': 'more_horiz', 'color': 0xFFA8D8EA, 'is_default': 1},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  Future<void> _insertDefaultAccounts(Database db) async {
    final defaultAccounts = [
      {'id': 'acc_cash', 'name': '现金', 'type': 'cash', 'balance': 0.0, 'icon': 'account_balance_wallet', 'color': 0xFF6BCB77},
      {'id': 'acc_alipay', 'name': '支付宝', 'type': 'alipay', 'balance': 0.0, 'icon': 'payment', 'color': 0xFF1677FF},
      {'id': 'acc_wechat', 'name': '微信', 'type': 'wechat', 'balance': 0.0, 'icon': 'chat', 'color': 0xFF07C160},
      {'id': 'acc_bank', 'name': '银行卡', 'type': 'bank', 'balance': 0.0, 'icon': 'account_balance', 'color': 0xFFFF6B6B},
    ];

    for (var acc in defaultAccounts) {
      await db.insert('accounts', acc);
    }
  }

  // ============ Transaction Operations ============
  
  Future<List<Transaction>> getTransactions({DateTime? month}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (month != null) {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      whereClause = 'WHERE date >= ? AND date <= ?';
      whereArgs = [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()];
    }
    
    final maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
    await _updateAccountBalance(transaction.accountId);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    // 获取旧交易记录以恢复余额
    final oldMaps = await db.query('transactions', where: 'id = ?', whereArgs: [transaction.id]);
    if (oldMaps.isNotEmpty) {
      final oldTransaction = Transaction.fromMap(oldMaps.first);
      await _updateAccountBalance(oldTransaction.accountId, reverse: true);
    }
    
    await db.update('transactions', transaction.toMap(), where: 'id = ?', whereArgs: [transaction.id]);
    await _updateAccountBalance(transaction.accountId);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final transaction = Transaction.fromMap(maps.first);
      await _updateAccountBalance(transaction.accountId, reverse: true);
    }
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Account Operations ============

  Future<List<Account>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts', orderBy: 'created_at ASC');
    return maps.map((map) => Account.fromMap(map)).toList();
  }

  Future<void> insertAccount(Account account) async {
    final db = await database;
    await db.insert('accounts', account.toMap());
  }

  Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _updateAccountBalance(String accountId, {bool reverse = false}) async {
    final db = await database;
    final transactions = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
    
    double balance = 0;
    for (var t in transactions) {
      balance += (t['amount'] as num).toDouble();
    }
    
    await db.update(
      'accounts',
      {'balance': balance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  // ============ Category Operations ============

  Future<List<Category>> getCategories({TransactionType? type}) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type.name] : null,
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Statistics ============

  Future<Map<String, double>> getMonthlyStats(int year, int month) async {
    final db = await database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final income = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total FROM transactions
      WHERE type = 'income' AND date >= ? AND date <= ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);
    
    final expense = await db.rawQuery('''
      SELECT COALESCE(SUM(ABS(amount)), 0) as total FROM transactions
      WHERE type = 'expense' AND date >= ? AND date <= ?
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);
    
    return {
      'income': (income.first['total'] as num).toDouble(),
      'expense': (expense.first['total'] as num).toDouble(),
    };
  }
  
  Future<void> init() async {
    await database;
  }
}
