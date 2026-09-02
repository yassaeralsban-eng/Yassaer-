/// Represents a report category (SAD section 10 - categories collection).
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.status,
    this.ordering = 0,
    this.parentId,
  });

  final String id;
  final String name;
  final String status;
  final int ordering;
  final String? parentId;

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'] as String,
    name: map['name'] as String,
    status: map['status'] as String? ?? 'active',
    ordering: (map['ordering'] as num?)?.toInt() ?? 0,
    parentId: map['parentId'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'status': status,
    'ordering': ordering,
    'parentId': parentId,
  };
}
