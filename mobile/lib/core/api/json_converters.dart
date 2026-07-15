import 'package:freezed_annotation/freezed_annotation.dart';

/// Laravel meng-cast kolom uang sebagai `decimal:2` sehingga JSON-nya
/// berupa string ("150000.00"). Converter ini menerima num maupun String.
class FlexDouble implements JsonConverter<double, Object?> {
  const FlexDouble();

  @override
  double fromJson(Object? json) => switch (json) {
        num n => n.toDouble(),
        String s => double.tryParse(s) ?? 0,
        _ => 0,
      };

  @override
  Object toJson(double value) => value;
}

class FlexDoubleNullable implements JsonConverter<double?, Object?> {
  const FlexDoubleNullable();

  @override
  double? fromJson(Object? json) => switch (json) {
        num n => n.toDouble(),
        String s => double.tryParse(s),
        _ => null,
      };

  @override
  Object? toJson(double? value) => value;
}
