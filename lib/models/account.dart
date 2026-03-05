import 'package:equatable/equatable.dart';

enum AccountType { cash, alipay, wechat, bank, creditCard, other }

class Account extends Equatable {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String icon;
  final int color;
  final DateTime createdAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    String? icon,
    int? color,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere((e) => e.name == map['type']),
      balance: (map['balance'] as num).toDouble(),
      icon: map['icon'] as String,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, type, balance, icon, color, createdAt];
}
