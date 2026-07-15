import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';

part 'product_models.freezed.dart';
part 'product_models.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? sku,
    String? description,
    @Default('pcs') String unit,
    @FlexDouble() @Default(0) double price,
    @FlexDoubleNullable() double? cost,
    String? category,
    String? imageUrl,
    @Default([]) List<String> images,
    @FlexDouble() @Default(0) double stockQty,
    @Default(true) bool isActive,
    @Default(false) bool showInCatalog,
    String? createdAt,
    String? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class ProductInput with _$ProductInput {
  const factory ProductInput({
    required String name,
    String? sku,
    String? description,
    required String unit,
    required double price,
    double? cost,
    String? category,
    double? stockQty,
    bool? isActive,
    bool? showInCatalog,
  }) = _ProductInput;

  factory ProductInput.fromJson(Map<String, dynamic> json) =>
      _$ProductInputFromJson(json);
}
