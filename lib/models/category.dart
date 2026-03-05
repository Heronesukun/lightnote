import 'package:equatable/equatable.dart';
import 'transaction.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final TransactionType type;
  final String icon;
  final int color;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isDefault,
  });

  Category copyWith({
    String? id,
    String? name,
    TransactionType? type,
    String? icon,
    int? color,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      icon: map['icon'] as String,
      color: map['color'] as int,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  @override
  List<Object?> get props => [id, name, type, icon, color, isDefault];
}
