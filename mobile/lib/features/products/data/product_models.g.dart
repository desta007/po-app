// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  sku: json['sku'] as String?,
  description: json['description'] as String?,
  unit: json['unit'] as String? ?? 'pcs',
  price: json['price'] == null ? 0 : const FlexDouble().fromJson(json['price']),
  cost: const FlexDoubleNullable().fromJson(json['cost']),
  category: json['category'] as String?,
  imageUrl: json['image_url'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  stockQty: json['stock_qty'] == null
      ? 0
      : const FlexDouble().fromJson(json['stock_qty']),
  isActive: json['is_active'] as bool? ?? true,
  showInCatalog: json['show_in_catalog'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'description': instance.description,
  'unit': instance.unit,
  'price': const FlexDouble().toJson(instance.price),
  'cost': const FlexDoubleNullable().toJson(instance.cost),
  'category': instance.category,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'stock_qty': const FlexDouble().toJson(instance.stockQty),
  'is_active': instance.isActive,
  'show_in_catalog': instance.showInCatalog,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_ProductInput _$ProductInputFromJson(Map<String, dynamic> json) =>
    _ProductInput(
      name: json['name'] as String,
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      unit: json['unit'] as String,
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      category: json['category'] as String?,
      stockQty: (json['stock_qty'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool?,
      showInCatalog: json['show_in_catalog'] as bool?,
    );

Map<String, dynamic> _$ProductInputToJson(_ProductInput instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'description': instance.description,
      'unit': instance.unit,
      'price': instance.price,
      'cost': instance.cost,
      'category': instance.category,
      'stock_qty': instance.stockQty,
      'is_active': instance.isActive,
      'show_in_catalog': instance.showInCatalog,
    };
