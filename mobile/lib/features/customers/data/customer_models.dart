import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/api/json_converters.dart';

part 'customer_models.freezed.dart';
part 'customer_models.g.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    @Default([]) List<String> tags,
    @Default(0) int totalOrders,
    @FlexDouble() @Default(0) double totalRevenue,
    String? createdAt,
    String? updatedAt,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

/// Payload create/update customer (field null tidak ikut dikirim).
@freezed
abstract class CustomerInput with _$CustomerInput {
  const factory CustomerInput({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    List<String>? tags,
  }) = _CustomerInput;

  factory CustomerInput.fromJson(Map<String, dynamic> json) =>
      _$CustomerInputFromJson(json);
}
