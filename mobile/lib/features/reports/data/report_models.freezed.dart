// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfitDataPoint {

 String get date;@FlexDouble() double get revenue;@FlexDouble() double get totalCost;@FlexDouble() double get profit;@FlexInt() int get orderCount;
/// Create a copy of ProfitDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfitDataPointCopyWith<ProfitDataPoint> get copyWith => _$ProfitDataPointCopyWithImpl<ProfitDataPoint>(this as ProfitDataPoint, _$identity);

  /// Serializes this ProfitDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfitDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,totalCost,profit,orderCount);

@override
String toString() {
  return 'ProfitDataPoint(date: $date, revenue: $revenue, totalCost: $totalCost, profit: $profit, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class $ProfitDataPointCopyWith<$Res>  {
  factory $ProfitDataPointCopyWith(ProfitDataPoint value, $Res Function(ProfitDataPoint) _then) = _$ProfitDataPointCopyWithImpl;
@useResult
$Res call({
 String date,@FlexDouble() double revenue,@FlexDouble() double totalCost,@FlexDouble() double profit,@FlexInt() int orderCount
});




}
/// @nodoc
class _$ProfitDataPointCopyWithImpl<$Res>
    implements $ProfitDataPointCopyWith<$Res> {
  _$ProfitDataPointCopyWithImpl(this._self, this._then);

  final ProfitDataPoint _self;
  final $Res Function(ProfitDataPoint) _then;

/// Create a copy of ProfitDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? revenue = null,Object? totalCost = null,Object? profit = null,Object? orderCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfitDataPoint].
extension ProfitDataPointPatterns on ProfitDataPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfitDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfitDataPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfitDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _ProfitDataPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfitDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _ProfitDataPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @FlexDouble()  double revenue, @FlexDouble()  double totalCost, @FlexDouble()  double profit, @FlexInt()  int orderCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfitDataPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.totalCost,_that.profit,_that.orderCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @FlexDouble()  double revenue, @FlexDouble()  double totalCost, @FlexDouble()  double profit, @FlexInt()  int orderCount)  $default,) {final _that = this;
switch (_that) {
case _ProfitDataPoint():
return $default(_that.date,_that.revenue,_that.totalCost,_that.profit,_that.orderCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @FlexDouble()  double revenue, @FlexDouble()  double totalCost, @FlexDouble()  double profit, @FlexInt()  int orderCount)?  $default,) {final _that = this;
switch (_that) {
case _ProfitDataPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.totalCost,_that.profit,_that.orderCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfitDataPoint implements ProfitDataPoint {
  const _ProfitDataPoint({required this.date, @FlexDouble() this.revenue = 0, @FlexDouble() this.totalCost = 0, @FlexDouble() this.profit = 0, @FlexInt() this.orderCount = 0});
  factory _ProfitDataPoint.fromJson(Map<String, dynamic> json) => _$ProfitDataPointFromJson(json);

@override final  String date;
@override@JsonKey()@FlexDouble() final  double revenue;
@override@JsonKey()@FlexDouble() final  double totalCost;
@override@JsonKey()@FlexDouble() final  double profit;
@override@JsonKey()@FlexInt() final  int orderCount;

/// Create a copy of ProfitDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfitDataPointCopyWith<_ProfitDataPoint> get copyWith => __$ProfitDataPointCopyWithImpl<_ProfitDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfitDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfitDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.profit, profit) || other.profit == profit)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,totalCost,profit,orderCount);

@override
String toString() {
  return 'ProfitDataPoint(date: $date, revenue: $revenue, totalCost: $totalCost, profit: $profit, orderCount: $orderCount)';
}


}

/// @nodoc
abstract mixin class _$ProfitDataPointCopyWith<$Res> implements $ProfitDataPointCopyWith<$Res> {
  factory _$ProfitDataPointCopyWith(_ProfitDataPoint value, $Res Function(_ProfitDataPoint) _then) = __$ProfitDataPointCopyWithImpl;
@override @useResult
$Res call({
 String date,@FlexDouble() double revenue,@FlexDouble() double totalCost,@FlexDouble() double profit,@FlexInt() int orderCount
});




}
/// @nodoc
class __$ProfitDataPointCopyWithImpl<$Res>
    implements _$ProfitDataPointCopyWith<$Res> {
  __$ProfitDataPointCopyWithImpl(this._self, this._then);

  final _ProfitDataPoint _self;
  final $Res Function(_ProfitDataPoint) _then;

/// Create a copy of ProfitDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? revenue = null,Object? totalCost = null,Object? profit = null,Object? orderCount = null,}) {
  return _then(_ProfitDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProfitSummary {

@FlexDouble() double get totalRevenue;@FlexDouble() double get totalCost;@FlexDouble() double get totalProfit;@FlexInt() int get totalOrders;
/// Create a copy of ProfitSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfitSummaryCopyWith<ProfitSummary> get copyWith => _$ProfitSummaryCopyWithImpl<ProfitSummary>(this as ProfitSummary, _$identity);

  /// Serializes this ProfitSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfitSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalProfit, totalProfit) || other.totalProfit == totalProfit)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,totalCost,totalProfit,totalOrders);

@override
String toString() {
  return 'ProfitSummary(totalRevenue: $totalRevenue, totalCost: $totalCost, totalProfit: $totalProfit, totalOrders: $totalOrders)';
}


}

/// @nodoc
abstract mixin class $ProfitSummaryCopyWith<$Res>  {
  factory $ProfitSummaryCopyWith(ProfitSummary value, $Res Function(ProfitSummary) _then) = _$ProfitSummaryCopyWithImpl;
@useResult
$Res call({
@FlexDouble() double totalRevenue,@FlexDouble() double totalCost,@FlexDouble() double totalProfit,@FlexInt() int totalOrders
});




}
/// @nodoc
class _$ProfitSummaryCopyWithImpl<$Res>
    implements $ProfitSummaryCopyWith<$Res> {
  _$ProfitSummaryCopyWithImpl(this._self, this._then);

  final ProfitSummary _self;
  final $Res Function(ProfitSummary) _then;

/// Create a copy of ProfitSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? totalCost = null,Object? totalProfit = null,Object? totalOrders = null,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalProfit: null == totalProfit ? _self.totalProfit : totalProfit // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfitSummary].
extension ProfitSummaryPatterns on ProfitSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfitSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfitSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfitSummary value)  $default,){
final _that = this;
switch (_that) {
case _ProfitSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfitSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ProfitSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@FlexDouble()  double totalRevenue, @FlexDouble()  double totalCost, @FlexDouble()  double totalProfit, @FlexInt()  int totalOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfitSummary() when $default != null:
return $default(_that.totalRevenue,_that.totalCost,_that.totalProfit,_that.totalOrders);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@FlexDouble()  double totalRevenue, @FlexDouble()  double totalCost, @FlexDouble()  double totalProfit, @FlexInt()  int totalOrders)  $default,) {final _that = this;
switch (_that) {
case _ProfitSummary():
return $default(_that.totalRevenue,_that.totalCost,_that.totalProfit,_that.totalOrders);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@FlexDouble()  double totalRevenue, @FlexDouble()  double totalCost, @FlexDouble()  double totalProfit, @FlexInt()  int totalOrders)?  $default,) {final _that = this;
switch (_that) {
case _ProfitSummary() when $default != null:
return $default(_that.totalRevenue,_that.totalCost,_that.totalProfit,_that.totalOrders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfitSummary implements ProfitSummary {
  const _ProfitSummary({@FlexDouble() this.totalRevenue = 0, @FlexDouble() this.totalCost = 0, @FlexDouble() this.totalProfit = 0, @FlexInt() this.totalOrders = 0});
  factory _ProfitSummary.fromJson(Map<String, dynamic> json) => _$ProfitSummaryFromJson(json);

@override@JsonKey()@FlexDouble() final  double totalRevenue;
@override@JsonKey()@FlexDouble() final  double totalCost;
@override@JsonKey()@FlexDouble() final  double totalProfit;
@override@JsonKey()@FlexInt() final  int totalOrders;

/// Create a copy of ProfitSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfitSummaryCopyWith<_ProfitSummary> get copyWith => __$ProfitSummaryCopyWithImpl<_ProfitSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfitSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfitSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.totalProfit, totalProfit) || other.totalProfit == totalProfit)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,totalCost,totalProfit,totalOrders);

@override
String toString() {
  return 'ProfitSummary(totalRevenue: $totalRevenue, totalCost: $totalCost, totalProfit: $totalProfit, totalOrders: $totalOrders)';
}


}

/// @nodoc
abstract mixin class _$ProfitSummaryCopyWith<$Res> implements $ProfitSummaryCopyWith<$Res> {
  factory _$ProfitSummaryCopyWith(_ProfitSummary value, $Res Function(_ProfitSummary) _then) = __$ProfitSummaryCopyWithImpl;
@override @useResult
$Res call({
@FlexDouble() double totalRevenue,@FlexDouble() double totalCost,@FlexDouble() double totalProfit,@FlexInt() int totalOrders
});




}
/// @nodoc
class __$ProfitSummaryCopyWithImpl<$Res>
    implements _$ProfitSummaryCopyWith<$Res> {
  __$ProfitSummaryCopyWithImpl(this._self, this._then);

  final _ProfitSummary _self;
  final $Res Function(_ProfitSummary) _then;

/// Create a copy of ProfitSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? totalCost = null,Object? totalProfit = null,Object? totalOrders = null,}) {
  return _then(_ProfitSummary(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,totalProfit: null == totalProfit ? _self.totalProfit : totalProfit // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProfitTopProduct {

 String get name;@FlexDouble() double get totalQty;@FlexDouble() double get revenue;@FlexDouble() double get cost;@FlexDouble() double get profit;
/// Create a copy of ProfitTopProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfitTopProductCopyWith<ProfitTopProduct> get copyWith => _$ProfitTopProductCopyWithImpl<ProfitTopProduct>(this as ProfitTopProduct, _$identity);

  /// Serializes this ProfitTopProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfitTopProduct&&(identical(other.name, name) || other.name == name)&&(identical(other.totalQty, totalQty) || other.totalQty == totalQty)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.profit, profit) || other.profit == profit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalQty,revenue,cost,profit);

@override
String toString() {
  return 'ProfitTopProduct(name: $name, totalQty: $totalQty, revenue: $revenue, cost: $cost, profit: $profit)';
}


}

/// @nodoc
abstract mixin class $ProfitTopProductCopyWith<$Res>  {
  factory $ProfitTopProductCopyWith(ProfitTopProduct value, $Res Function(ProfitTopProduct) _then) = _$ProfitTopProductCopyWithImpl;
@useResult
$Res call({
 String name,@FlexDouble() double totalQty,@FlexDouble() double revenue,@FlexDouble() double cost,@FlexDouble() double profit
});




}
/// @nodoc
class _$ProfitTopProductCopyWithImpl<$Res>
    implements $ProfitTopProductCopyWith<$Res> {
  _$ProfitTopProductCopyWithImpl(this._self, this._then);

  final ProfitTopProduct _self;
  final $Res Function(ProfitTopProduct) _then;

/// Create a copy of ProfitTopProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? totalQty = null,Object? revenue = null,Object? cost = null,Object? profit = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalQty: null == totalQty ? _self.totalQty : totalQty // ignore: cast_nullable_to_non_nullable
as double,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfitTopProduct].
extension ProfitTopProductPatterns on ProfitTopProduct {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfitTopProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfitTopProduct() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfitTopProduct value)  $default,){
final _that = this;
switch (_that) {
case _ProfitTopProduct():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfitTopProduct value)?  $default,){
final _that = this;
switch (_that) {
case _ProfitTopProduct() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @FlexDouble()  double totalQty, @FlexDouble()  double revenue, @FlexDouble()  double cost, @FlexDouble()  double profit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfitTopProduct() when $default != null:
return $default(_that.name,_that.totalQty,_that.revenue,_that.cost,_that.profit);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @FlexDouble()  double totalQty, @FlexDouble()  double revenue, @FlexDouble()  double cost, @FlexDouble()  double profit)  $default,) {final _that = this;
switch (_that) {
case _ProfitTopProduct():
return $default(_that.name,_that.totalQty,_that.revenue,_that.cost,_that.profit);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @FlexDouble()  double totalQty, @FlexDouble()  double revenue, @FlexDouble()  double cost, @FlexDouble()  double profit)?  $default,) {final _that = this;
switch (_that) {
case _ProfitTopProduct() when $default != null:
return $default(_that.name,_that.totalQty,_that.revenue,_that.cost,_that.profit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfitTopProduct implements ProfitTopProduct {
  const _ProfitTopProduct({required this.name, @FlexDouble() this.totalQty = 0, @FlexDouble() this.revenue = 0, @FlexDouble() this.cost = 0, @FlexDouble() this.profit = 0});
  factory _ProfitTopProduct.fromJson(Map<String, dynamic> json) => _$ProfitTopProductFromJson(json);

@override final  String name;
@override@JsonKey()@FlexDouble() final  double totalQty;
@override@JsonKey()@FlexDouble() final  double revenue;
@override@JsonKey()@FlexDouble() final  double cost;
@override@JsonKey()@FlexDouble() final  double profit;

/// Create a copy of ProfitTopProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfitTopProductCopyWith<_ProfitTopProduct> get copyWith => __$ProfitTopProductCopyWithImpl<_ProfitTopProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfitTopProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfitTopProduct&&(identical(other.name, name) || other.name == name)&&(identical(other.totalQty, totalQty) || other.totalQty == totalQty)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.profit, profit) || other.profit == profit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,totalQty,revenue,cost,profit);

@override
String toString() {
  return 'ProfitTopProduct(name: $name, totalQty: $totalQty, revenue: $revenue, cost: $cost, profit: $profit)';
}


}

/// @nodoc
abstract mixin class _$ProfitTopProductCopyWith<$Res> implements $ProfitTopProductCopyWith<$Res> {
  factory _$ProfitTopProductCopyWith(_ProfitTopProduct value, $Res Function(_ProfitTopProduct) _then) = __$ProfitTopProductCopyWithImpl;
@override @useResult
$Res call({
 String name,@FlexDouble() double totalQty,@FlexDouble() double revenue,@FlexDouble() double cost,@FlexDouble() double profit
});




}
/// @nodoc
class __$ProfitTopProductCopyWithImpl<$Res>
    implements _$ProfitTopProductCopyWith<$Res> {
  __$ProfitTopProductCopyWithImpl(this._self, this._then);

  final _ProfitTopProduct _self;
  final $Res Function(_ProfitTopProduct) _then;

/// Create a copy of ProfitTopProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? totalQty = null,Object? revenue = null,Object? cost = null,Object? profit = null,}) {
  return _then(_ProfitTopProduct(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalQty: null == totalQty ? _self.totalQty : totalQty // ignore: cast_nullable_to_non_nullable
as double,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,profit: null == profit ? _self.profit : profit // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ProfitReport {

 List<ProfitDataPoint> get chart; ProfitSummary? get summary; List<ProfitTopProduct> get topProducts;
/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfitReportCopyWith<ProfitReport> get copyWith => _$ProfitReportCopyWithImpl<ProfitReport>(this as ProfitReport, _$identity);

  /// Serializes this ProfitReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfitReport&&const DeepCollectionEquality().equals(other.chart, chart)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.topProducts, topProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(chart),summary,const DeepCollectionEquality().hash(topProducts));

@override
String toString() {
  return 'ProfitReport(chart: $chart, summary: $summary, topProducts: $topProducts)';
}


}

/// @nodoc
abstract mixin class $ProfitReportCopyWith<$Res>  {
  factory $ProfitReportCopyWith(ProfitReport value, $Res Function(ProfitReport) _then) = _$ProfitReportCopyWithImpl;
@useResult
$Res call({
 List<ProfitDataPoint> chart, ProfitSummary? summary, List<ProfitTopProduct> topProducts
});


$ProfitSummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class _$ProfitReportCopyWithImpl<$Res>
    implements $ProfitReportCopyWith<$Res> {
  _$ProfitReportCopyWithImpl(this._self, this._then);

  final ProfitReport _self;
  final $Res Function(ProfitReport) _then;

/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chart = null,Object? summary = freezed,Object? topProducts = null,}) {
  return _then(_self.copyWith(
chart: null == chart ? _self.chart : chart // ignore: cast_nullable_to_non_nullable
as List<ProfitDataPoint>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ProfitSummary?,topProducts: null == topProducts ? _self.topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<ProfitTopProduct>,
  ));
}
/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfitSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $ProfitSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfitReport].
extension ProfitReportPatterns on ProfitReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfitReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfitReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfitReport value)  $default,){
final _that = this;
switch (_that) {
case _ProfitReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfitReport value)?  $default,){
final _that = this;
switch (_that) {
case _ProfitReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProfitDataPoint> chart,  ProfitSummary? summary,  List<ProfitTopProduct> topProducts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfitReport() when $default != null:
return $default(_that.chart,_that.summary,_that.topProducts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProfitDataPoint> chart,  ProfitSummary? summary,  List<ProfitTopProduct> topProducts)  $default,) {final _that = this;
switch (_that) {
case _ProfitReport():
return $default(_that.chart,_that.summary,_that.topProducts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProfitDataPoint> chart,  ProfitSummary? summary,  List<ProfitTopProduct> topProducts)?  $default,) {final _that = this;
switch (_that) {
case _ProfitReport() when $default != null:
return $default(_that.chart,_that.summary,_that.topProducts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfitReport implements ProfitReport {
  const _ProfitReport({final  List<ProfitDataPoint> chart = const [], this.summary, final  List<ProfitTopProduct> topProducts = const []}): _chart = chart,_topProducts = topProducts;
  factory _ProfitReport.fromJson(Map<String, dynamic> json) => _$ProfitReportFromJson(json);

 final  List<ProfitDataPoint> _chart;
@override@JsonKey() List<ProfitDataPoint> get chart {
  if (_chart is EqualUnmodifiableListView) return _chart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chart);
}

@override final  ProfitSummary? summary;
 final  List<ProfitTopProduct> _topProducts;
@override@JsonKey() List<ProfitTopProduct> get topProducts {
  if (_topProducts is EqualUnmodifiableListView) return _topProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topProducts);
}


/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfitReportCopyWith<_ProfitReport> get copyWith => __$ProfitReportCopyWithImpl<_ProfitReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfitReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfitReport&&const DeepCollectionEquality().equals(other._chart, _chart)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._topProducts, _topProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_chart),summary,const DeepCollectionEquality().hash(_topProducts));

@override
String toString() {
  return 'ProfitReport(chart: $chart, summary: $summary, topProducts: $topProducts)';
}


}

/// @nodoc
abstract mixin class _$ProfitReportCopyWith<$Res> implements $ProfitReportCopyWith<$Res> {
  factory _$ProfitReportCopyWith(_ProfitReport value, $Res Function(_ProfitReport) _then) = __$ProfitReportCopyWithImpl;
@override @useResult
$Res call({
 List<ProfitDataPoint> chart, ProfitSummary? summary, List<ProfitTopProduct> topProducts
});


@override $ProfitSummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class __$ProfitReportCopyWithImpl<$Res>
    implements _$ProfitReportCopyWith<$Res> {
  __$ProfitReportCopyWithImpl(this._self, this._then);

  final _ProfitReport _self;
  final $Res Function(_ProfitReport) _then;

/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chart = null,Object? summary = freezed,Object? topProducts = null,}) {
  return _then(_ProfitReport(
chart: null == chart ? _self._chart : chart // ignore: cast_nullable_to_non_nullable
as List<ProfitDataPoint>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as ProfitSummary?,topProducts: null == topProducts ? _self._topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<ProfitTopProduct>,
  ));
}

/// Create a copy of ProfitReport
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfitSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $ProfitSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
