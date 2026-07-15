// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'po_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PurchaseOrderItem {

 String? get id; String? get productId; String get productName;@FlexDouble() double get quantity;@FlexDouble() double get unitPrice;@FlexDouble() double get subtotal; String? get notes; int get sortOrder;
/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderItemCopyWith<PurchaseOrderItem> get copyWith => _$PurchaseOrderItemCopyWithImpl<PurchaseOrderItem>(this as PurchaseOrderItem, _$identity);

  /// Serializes this PurchaseOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,quantity,unitPrice,subtotal,notes,sortOrder);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal, notes: $notes, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderItemCopyWith<$Res>  {
  factory $PurchaseOrderItemCopyWith(PurchaseOrderItem value, $Res Function(PurchaseOrderItem) _then) = _$PurchaseOrderItemCopyWithImpl;
@useResult
$Res call({
 String? id, String? productId, String productName,@FlexDouble() double quantity,@FlexDouble() double unitPrice,@FlexDouble() double subtotal, String? notes, int sortOrder
});




}
/// @nodoc
class _$PurchaseOrderItemCopyWithImpl<$Res>
    implements $PurchaseOrderItemCopyWith<$Res> {
  _$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final PurchaseOrderItem _self;
  final $Res Function(PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,Object? notes = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseOrderItem].
extension PurchaseOrderItemPatterns on PurchaseOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? productId,  String productName, @FlexDouble()  double quantity, @FlexDouble()  double unitPrice, @FlexDouble()  double subtotal,  String? notes,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.subtotal,_that.notes,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? productId,  String productName, @FlexDouble()  double quantity, @FlexDouble()  double unitPrice, @FlexDouble()  double subtotal,  String? notes,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem():
return $default(_that.id,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.subtotal,_that.notes,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? productId,  String productName, @FlexDouble()  double quantity, @FlexDouble()  double unitPrice, @FlexDouble()  double subtotal,  String? notes,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrderItem() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.subtotal,_that.notes,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrderItem implements PurchaseOrderItem {
  const _PurchaseOrderItem({this.id, this.productId, required this.productName, @FlexDouble() required this.quantity, @FlexDouble() required this.unitPrice, @FlexDouble() this.subtotal = 0, this.notes, this.sortOrder = 0});
  factory _PurchaseOrderItem.fromJson(Map<String, dynamic> json) => _$PurchaseOrderItemFromJson(json);

@override final  String? id;
@override final  String? productId;
@override final  String productName;
@override@FlexDouble() final  double quantity;
@override@FlexDouble() final  double unitPrice;
@override@JsonKey()@FlexDouble() final  double subtotal;
@override final  String? notes;
@override@JsonKey() final  int sortOrder;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderItemCopyWith<_PurchaseOrderItem> get copyWith => __$PurchaseOrderItemCopyWithImpl<_PurchaseOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,quantity,unitPrice,subtotal,notes,sortOrder);

@override
String toString() {
  return 'PurchaseOrderItem(id: $id, productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal, notes: $notes, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderItemCopyWith<$Res> implements $PurchaseOrderItemCopyWith<$Res> {
  factory _$PurchaseOrderItemCopyWith(_PurchaseOrderItem value, $Res Function(_PurchaseOrderItem) _then) = __$PurchaseOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? productId, String productName,@FlexDouble() double quantity,@FlexDouble() double unitPrice,@FlexDouble() double subtotal, String? notes, int sortOrder
});




}
/// @nodoc
class __$PurchaseOrderItemCopyWithImpl<$Res>
    implements _$PurchaseOrderItemCopyWith<$Res> {
  __$PurchaseOrderItemCopyWithImpl(this._self, this._then);

  final _PurchaseOrderItem _self;
  final $Res Function(_PurchaseOrderItem) _then;

/// Create a copy of PurchaseOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,Object? notes = freezed,Object? sortOrder = null,}) {
  return _then(_PurchaseOrderItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PoStatusHistory {

 String? get id;@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus? get fromStatus;@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus get toStatus; String? get changedBy; String? get reason; String? get changedAt;
/// Create a copy of PoStatusHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoStatusHistoryCopyWith<PoStatusHistory> get copyWith => _$PoStatusHistoryCopyWithImpl<PoStatusHistory>(this as PoStatusHistory, _$identity);

  /// Serializes this PoStatusHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoStatusHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromStatus,toStatus,changedBy,reason,changedAt);

@override
String toString() {
  return 'PoStatusHistory(id: $id, fromStatus: $fromStatus, toStatus: $toStatus, changedBy: $changedBy, reason: $reason, changedAt: $changedAt)';
}


}

/// @nodoc
abstract mixin class $PoStatusHistoryCopyWith<$Res>  {
  factory $PoStatusHistoryCopyWith(PoStatusHistory value, $Res Function(PoStatusHistory) _then) = _$PoStatusHistoryCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus? fromStatus,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus toStatus, String? changedBy, String? reason, String? changedAt
});




}
/// @nodoc
class _$PoStatusHistoryCopyWithImpl<$Res>
    implements $PoStatusHistoryCopyWith<$Res> {
  _$PoStatusHistoryCopyWithImpl(this._self, this._then);

  final PoStatusHistory _self;
  final $Res Function(PoStatusHistory) _then;

/// Create a copy of PoStatusHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fromStatus = freezed,Object? toStatus = null,Object? changedBy = freezed,Object? reason = freezed,Object? changedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as PoStatus?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as PoStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PoStatusHistory].
extension PoStatusHistoryPatterns on PoStatusHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoStatusHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoStatusHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoStatusHistory value)  $default,){
final _that = this;
switch (_that) {
case _PoStatusHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoStatusHistory value)?  $default,){
final _that = this;
switch (_that) {
case _PoStatusHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus? fromStatus, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus toStatus,  String? changedBy,  String? reason,  String? changedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoStatusHistory() when $default != null:
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.changedBy,_that.reason,_that.changedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus? fromStatus, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus toStatus,  String? changedBy,  String? reason,  String? changedAt)  $default,) {final _that = this;
switch (_that) {
case _PoStatusHistory():
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.changedBy,_that.reason,_that.changedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus? fromStatus, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus toStatus,  String? changedBy,  String? reason,  String? changedAt)?  $default,) {final _that = this;
switch (_that) {
case _PoStatusHistory() when $default != null:
return $default(_that.id,_that.fromStatus,_that.toStatus,_that.changedBy,_that.reason,_that.changedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoStatusHistory implements PoStatusHistory {
  const _PoStatusHistory({this.id, @JsonKey(unknownEnumValue: PoStatus.draft) this.fromStatus, @JsonKey(unknownEnumValue: PoStatus.draft) required this.toStatus, this.changedBy, this.reason, this.changedAt});
  factory _PoStatusHistory.fromJson(Map<String, dynamic> json) => _$PoStatusHistoryFromJson(json);

@override final  String? id;
@override@JsonKey(unknownEnumValue: PoStatus.draft) final  PoStatus? fromStatus;
@override@JsonKey(unknownEnumValue: PoStatus.draft) final  PoStatus toStatus;
@override final  String? changedBy;
@override final  String? reason;
@override final  String? changedAt;

/// Create a copy of PoStatusHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoStatusHistoryCopyWith<_PoStatusHistory> get copyWith => __$PoStatusHistoryCopyWithImpl<_PoStatusHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoStatusHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoStatusHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.fromStatus, fromStatus) || other.fromStatus == fromStatus)&&(identical(other.toStatus, toStatus) || other.toStatus == toStatus)&&(identical(other.changedBy, changedBy) || other.changedBy == changedBy)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.changedAt, changedAt) || other.changedAt == changedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromStatus,toStatus,changedBy,reason,changedAt);

@override
String toString() {
  return 'PoStatusHistory(id: $id, fromStatus: $fromStatus, toStatus: $toStatus, changedBy: $changedBy, reason: $reason, changedAt: $changedAt)';
}


}

/// @nodoc
abstract mixin class _$PoStatusHistoryCopyWith<$Res> implements $PoStatusHistoryCopyWith<$Res> {
  factory _$PoStatusHistoryCopyWith(_PoStatusHistory value, $Res Function(_PoStatusHistory) _then) = __$PoStatusHistoryCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus? fromStatus,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus toStatus, String? changedBy, String? reason, String? changedAt
});




}
/// @nodoc
class __$PoStatusHistoryCopyWithImpl<$Res>
    implements _$PoStatusHistoryCopyWith<$Res> {
  __$PoStatusHistoryCopyWithImpl(this._self, this._then);

  final _PoStatusHistory _self;
  final $Res Function(_PoStatusHistory) _then;

/// Create a copy of PoStatusHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fromStatus = freezed,Object? toStatus = null,Object? changedBy = freezed,Object? reason = freezed,Object? changedAt = freezed,}) {
  return _then(_PoStatusHistory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fromStatus: freezed == fromStatus ? _self.fromStatus : fromStatus // ignore: cast_nullable_to_non_nullable
as PoStatus?,toStatus: null == toStatus ? _self.toStatus : toStatus // ignore: cast_nullable_to_non_nullable
as PoStatus,changedBy: freezed == changedBy ? _self.changedBy : changedBy // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,changedAt: freezed == changedAt ? _self.changedAt : changedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PurchaseOrder {

 String get id; String get poNumber; String get customerId; Customer? get customer; String get orderDate; String get deliveryDate;@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus get status;@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus get paymentStatus;@FlexDouble() double get dpAmount;@FlexDouble() double get paidAmount;@FlexDouble() double get subtotal;@FlexDouble() double get discount;@FlexDouble() double get tax;@FlexDouble() double get shippingCost;@FlexDouble() double get total; String? get notes; String? get paymentMethod; List<PurchaseOrderItem> get items; List<PoStatusHistory> get statusHistory; String? get createdAt; String? get updatedAt;
/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseOrderCopyWith<PurchaseOrder> get copyWith => _$PurchaseOrderCopyWithImpl<PurchaseOrder>(this as PurchaseOrder, _$identity);

  /// Serializes this PurchaseOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.poNumber, poNumber) || other.poNumber == poNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.dpAmount, dpAmount) || other.dpAmount == dpAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.statusHistory, statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,poNumber,customerId,customer,orderDate,deliveryDate,status,paymentStatus,dpAmount,paidAmount,subtotal,discount,tax,shippingCost,total,notes,paymentMethod,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(statusHistory),createdAt,updatedAt]);

@override
String toString() {
  return 'PurchaseOrder(id: $id, poNumber: $poNumber, customerId: $customerId, customer: $customer, orderDate: $orderDate, deliveryDate: $deliveryDate, status: $status, paymentStatus: $paymentStatus, dpAmount: $dpAmount, paidAmount: $paidAmount, subtotal: $subtotal, discount: $discount, tax: $tax, shippingCost: $shippingCost, total: $total, notes: $notes, paymentMethod: $paymentMethod, items: $items, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseOrderCopyWith<$Res>  {
  factory $PurchaseOrderCopyWith(PurchaseOrder value, $Res Function(PurchaseOrder) _then) = _$PurchaseOrderCopyWithImpl;
@useResult
$Res call({
 String id, String poNumber, String customerId, Customer? customer, String orderDate, String deliveryDate,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus status,@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus paymentStatus,@FlexDouble() double dpAmount,@FlexDouble() double paidAmount,@FlexDouble() double subtotal,@FlexDouble() double discount,@FlexDouble() double tax,@FlexDouble() double shippingCost,@FlexDouble() double total, String? notes, String? paymentMethod, List<PurchaseOrderItem> items, List<PoStatusHistory> statusHistory, String? createdAt, String? updatedAt
});


$CustomerCopyWith<$Res>? get customer;

}
/// @nodoc
class _$PurchaseOrderCopyWithImpl<$Res>
    implements $PurchaseOrderCopyWith<$Res> {
  _$PurchaseOrderCopyWithImpl(this._self, this._then);

  final PurchaseOrder _self;
  final $Res Function(PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? poNumber = null,Object? customerId = null,Object? customer = freezed,Object? orderDate = null,Object? deliveryDate = null,Object? status = null,Object? paymentStatus = null,Object? dpAmount = null,Object? paidAmount = null,Object? subtotal = null,Object? discount = null,Object? tax = null,Object? shippingCost = null,Object? total = null,Object? notes = freezed,Object? paymentMethod = freezed,Object? items = null,Object? statusHistory = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,poNumber: null == poNumber ? _self.poNumber : poNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,dpAmount: null == dpAmount ? _self.dpAmount : dpAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderItem>,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<PoStatusHistory>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseOrder].
extension PurchaseOrderPatterns on PurchaseOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseOrder value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseOrder value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String poNumber,  String customerId,  Customer? customer,  String orderDate,  String deliveryDate, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double dpAmount, @FlexDouble()  double paidAmount, @FlexDouble()  double subtotal, @FlexDouble()  double discount, @FlexDouble()  double tax, @FlexDouble()  double shippingCost, @FlexDouble()  double total,  String? notes,  String? paymentMethod,  List<PurchaseOrderItem> items,  List<PoStatusHistory> statusHistory,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.poNumber,_that.customerId,_that.customer,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.dpAmount,_that.paidAmount,_that.subtotal,_that.discount,_that.tax,_that.shippingCost,_that.total,_that.notes,_that.paymentMethod,_that.items,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String poNumber,  String customerId,  Customer? customer,  String orderDate,  String deliveryDate, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double dpAmount, @FlexDouble()  double paidAmount, @FlexDouble()  double subtotal, @FlexDouble()  double discount, @FlexDouble()  double tax, @FlexDouble()  double shippingCost, @FlexDouble()  double total,  String? notes,  String? paymentMethod,  List<PurchaseOrderItem> items,  List<PoStatusHistory> statusHistory,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder():
return $default(_that.id,_that.poNumber,_that.customerId,_that.customer,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.dpAmount,_that.paidAmount,_that.subtotal,_that.discount,_that.tax,_that.shippingCost,_that.total,_that.notes,_that.paymentMethod,_that.items,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String poNumber,  String customerId,  Customer? customer,  String orderDate,  String deliveryDate, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double dpAmount, @FlexDouble()  double paidAmount, @FlexDouble()  double subtotal, @FlexDouble()  double discount, @FlexDouble()  double tax, @FlexDouble()  double shippingCost, @FlexDouble()  double total,  String? notes,  String? paymentMethod,  List<PurchaseOrderItem> items,  List<PoStatusHistory> statusHistory,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseOrder() when $default != null:
return $default(_that.id,_that.poNumber,_that.customerId,_that.customer,_that.orderDate,_that.deliveryDate,_that.status,_that.paymentStatus,_that.dpAmount,_that.paidAmount,_that.subtotal,_that.discount,_that.tax,_that.shippingCost,_that.total,_that.notes,_that.paymentMethod,_that.items,_that.statusHistory,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseOrder implements PurchaseOrder {
  const _PurchaseOrder({required this.id, required this.poNumber, required this.customerId, this.customer, required this.orderDate, required this.deliveryDate, @JsonKey(unknownEnumValue: PoStatus.draft) required this.status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid) required this.paymentStatus, @FlexDouble() this.dpAmount = 0, @FlexDouble() this.paidAmount = 0, @FlexDouble() this.subtotal = 0, @FlexDouble() this.discount = 0, @FlexDouble() this.tax = 0, @FlexDouble() this.shippingCost = 0, @FlexDouble() this.total = 0, this.notes, this.paymentMethod, final  List<PurchaseOrderItem> items = const [], final  List<PoStatusHistory> statusHistory = const [], this.createdAt, this.updatedAt}): _items = items,_statusHistory = statusHistory;
  factory _PurchaseOrder.fromJson(Map<String, dynamic> json) => _$PurchaseOrderFromJson(json);

@override final  String id;
@override final  String poNumber;
@override final  String customerId;
@override final  Customer? customer;
@override final  String orderDate;
@override final  String deliveryDate;
@override@JsonKey(unknownEnumValue: PoStatus.draft) final  PoStatus status;
@override@JsonKey(unknownEnumValue: PaymentStatus.unpaid) final  PaymentStatus paymentStatus;
@override@JsonKey()@FlexDouble() final  double dpAmount;
@override@JsonKey()@FlexDouble() final  double paidAmount;
@override@JsonKey()@FlexDouble() final  double subtotal;
@override@JsonKey()@FlexDouble() final  double discount;
@override@JsonKey()@FlexDouble() final  double tax;
@override@JsonKey()@FlexDouble() final  double shippingCost;
@override@JsonKey()@FlexDouble() final  double total;
@override final  String? notes;
@override final  String? paymentMethod;
 final  List<PurchaseOrderItem> _items;
@override@JsonKey() List<PurchaseOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<PoStatusHistory> _statusHistory;
@override@JsonKey() List<PoStatusHistory> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseOrderCopyWith<_PurchaseOrder> get copyWith => __$PurchaseOrderCopyWithImpl<_PurchaseOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.poNumber, poNumber) || other.poNumber == poNumber)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.dpAmount, dpAmount) || other.dpAmount == dpAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.total, total) || other.total == total)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._statusHistory, _statusHistory)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,poNumber,customerId,customer,orderDate,deliveryDate,status,paymentStatus,dpAmount,paidAmount,subtotal,discount,tax,shippingCost,total,notes,paymentMethod,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_statusHistory),createdAt,updatedAt]);

@override
String toString() {
  return 'PurchaseOrder(id: $id, poNumber: $poNumber, customerId: $customerId, customer: $customer, orderDate: $orderDate, deliveryDate: $deliveryDate, status: $status, paymentStatus: $paymentStatus, dpAmount: $dpAmount, paidAmount: $paidAmount, subtotal: $subtotal, discount: $discount, tax: $tax, shippingCost: $shippingCost, total: $total, notes: $notes, paymentMethod: $paymentMethod, items: $items, statusHistory: $statusHistory, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseOrderCopyWith<$Res> implements $PurchaseOrderCopyWith<$Res> {
  factory _$PurchaseOrderCopyWith(_PurchaseOrder value, $Res Function(_PurchaseOrder) _then) = __$PurchaseOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String poNumber, String customerId, Customer? customer, String orderDate, String deliveryDate,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus status,@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus paymentStatus,@FlexDouble() double dpAmount,@FlexDouble() double paidAmount,@FlexDouble() double subtotal,@FlexDouble() double discount,@FlexDouble() double tax,@FlexDouble() double shippingCost,@FlexDouble() double total, String? notes, String? paymentMethod, List<PurchaseOrderItem> items, List<PoStatusHistory> statusHistory, String? createdAt, String? updatedAt
});


@override $CustomerCopyWith<$Res>? get customer;

}
/// @nodoc
class __$PurchaseOrderCopyWithImpl<$Res>
    implements _$PurchaseOrderCopyWith<$Res> {
  __$PurchaseOrderCopyWithImpl(this._self, this._then);

  final _PurchaseOrder _self;
  final $Res Function(_PurchaseOrder) _then;

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? poNumber = null,Object? customerId = null,Object? customer = freezed,Object? orderDate = null,Object? deliveryDate = null,Object? status = null,Object? paymentStatus = null,Object? dpAmount = null,Object? paidAmount = null,Object? subtotal = null,Object? discount = null,Object? tax = null,Object? shippingCost = null,Object? total = null,Object? notes = freezed,Object? paymentMethod = freezed,Object? items = null,Object? statusHistory = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PurchaseOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,poNumber: null == poNumber ? _self.poNumber : poNumber // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customer: freezed == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer?,orderDate: null == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,dpAmount: null == dpAmount ? _self.dpAmount : dpAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,shippingCost: null == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseOrderItem>,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<PoStatusHistory>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PurchaseOrder
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCopyWith<$Res>? get customer {
    if (_self.customer == null) {
    return null;
  }

  return $CustomerCopyWith<$Res>(_self.customer!, (value) {
    return _then(_self.copyWith(customer: value));
  });
}
}


/// @nodoc
mixin _$PoItemInput {

 String? get productId; String get productName; double get quantity; double get unitPrice; String? get notes;
/// Create a copy of PoItemInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoItemInputCopyWith<PoItemInput> get copyWith => _$PoItemInputCopyWithImpl<PoItemInput>(this as PoItemInput, _$identity);

  /// Serializes this PoItemInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoItemInput&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,quantity,unitPrice,notes);

@override
String toString() {
  return 'PoItemInput(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $PoItemInputCopyWith<$Res>  {
  factory $PoItemInputCopyWith(PoItemInput value, $Res Function(PoItemInput) _then) = _$PoItemInputCopyWithImpl;
@useResult
$Res call({
 String? productId, String productName, double quantity, double unitPrice, String? notes
});




}
/// @nodoc
class _$PoItemInputCopyWithImpl<$Res>
    implements $PoItemInputCopyWith<$Res> {
  _$PoItemInputCopyWithImpl(this._self, this._then);

  final PoItemInput _self;
  final $Res Function(PoItemInput) _then;

/// Create a copy of PoItemInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PoItemInput].
extension PoItemInputPatterns on PoItemInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoItemInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoItemInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoItemInput value)  $default,){
final _that = this;
switch (_that) {
case _PoItemInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoItemInput value)?  $default,){
final _that = this;
switch (_that) {
case _PoItemInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? productId,  String productName,  double quantity,  double unitPrice,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoItemInput() when $default != null:
return $default(_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? productId,  String productName,  double quantity,  double unitPrice,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _PoItemInput():
return $default(_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? productId,  String productName,  double quantity,  double unitPrice,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _PoItemInput() when $default != null:
return $default(_that.productId,_that.productName,_that.quantity,_that.unitPrice,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoItemInput implements PoItemInput {
  const _PoItemInput({this.productId, required this.productName, required this.quantity, required this.unitPrice, this.notes});
  factory _PoItemInput.fromJson(Map<String, dynamic> json) => _$PoItemInputFromJson(json);

@override final  String? productId;
@override final  String productName;
@override final  double quantity;
@override final  double unitPrice;
@override final  String? notes;

/// Create a copy of PoItemInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoItemInputCopyWith<_PoItemInput> get copyWith => __$PoItemInputCopyWithImpl<_PoItemInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoItemInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoItemInput&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,quantity,unitPrice,notes);

@override
String toString() {
  return 'PoItemInput(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$PoItemInputCopyWith<$Res> implements $PoItemInputCopyWith<$Res> {
  factory _$PoItemInputCopyWith(_PoItemInput value, $Res Function(_PoItemInput) _then) = __$PoItemInputCopyWithImpl;
@override @useResult
$Res call({
 String? productId, String productName, double quantity, double unitPrice, String? notes
});




}
/// @nodoc
class __$PoItemInputCopyWithImpl<$Res>
    implements _$PoItemInputCopyWith<$Res> {
  __$PoItemInputCopyWithImpl(this._self, this._then);

  final _PoItemInput _self;
  final $Res Function(_PoItemInput) _then;

/// Create a copy of PoItemInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = freezed,Object? productName = null,Object? quantity = null,Object? unitPrice = null,Object? notes = freezed,}) {
  return _then(_PoItemInput(
productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PoInput {

 String get customerId; String? get orderDate; String get deliveryDate; String? get notes; double? get discount; double? get tax; double? get shippingCost; double? get dpAmount; List<PoItemInput> get items;
/// Create a copy of PoInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoInputCopyWith<PoInput> get copyWith => _$PoInputCopyWithImpl<PoInput>(this as PoInput, _$identity);

  /// Serializes this PoInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PoInput&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.dpAmount, dpAmount) || other.dpAmount == dpAmount)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,orderDate,deliveryDate,notes,discount,tax,shippingCost,dpAmount,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'PoInput(customerId: $customerId, orderDate: $orderDate, deliveryDate: $deliveryDate, notes: $notes, discount: $discount, tax: $tax, shippingCost: $shippingCost, dpAmount: $dpAmount, items: $items)';
}


}

/// @nodoc
abstract mixin class $PoInputCopyWith<$Res>  {
  factory $PoInputCopyWith(PoInput value, $Res Function(PoInput) _then) = _$PoInputCopyWithImpl;
@useResult
$Res call({
 String customerId, String? orderDate, String deliveryDate, String? notes, double? discount, double? tax, double? shippingCost, double? dpAmount, List<PoItemInput> items
});




}
/// @nodoc
class _$PoInputCopyWithImpl<$Res>
    implements $PoInputCopyWith<$Res> {
  _$PoInputCopyWithImpl(this._self, this._then);

  final PoInput _self;
  final $Res Function(PoInput) _then;

/// Create a copy of PoInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customerId = null,Object? orderDate = freezed,Object? deliveryDate = null,Object? notes = freezed,Object? discount = freezed,Object? tax = freezed,Object? shippingCost = freezed,Object? dpAmount = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String?,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,tax: freezed == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double?,shippingCost: freezed == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double?,dpAmount: freezed == dpAmount ? _self.dpAmount : dpAmount // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PoItemInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [PoInput].
extension PoInputPatterns on PoInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PoInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PoInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PoInput value)  $default,){
final _that = this;
switch (_that) {
case _PoInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PoInput value)?  $default,){
final _that = this;
switch (_that) {
case _PoInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String customerId,  String? orderDate,  String deliveryDate,  String? notes,  double? discount,  double? tax,  double? shippingCost,  double? dpAmount,  List<PoItemInput> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PoInput() when $default != null:
return $default(_that.customerId,_that.orderDate,_that.deliveryDate,_that.notes,_that.discount,_that.tax,_that.shippingCost,_that.dpAmount,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String customerId,  String? orderDate,  String deliveryDate,  String? notes,  double? discount,  double? tax,  double? shippingCost,  double? dpAmount,  List<PoItemInput> items)  $default,) {final _that = this;
switch (_that) {
case _PoInput():
return $default(_that.customerId,_that.orderDate,_that.deliveryDate,_that.notes,_that.discount,_that.tax,_that.shippingCost,_that.dpAmount,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String customerId,  String? orderDate,  String deliveryDate,  String? notes,  double? discount,  double? tax,  double? shippingCost,  double? dpAmount,  List<PoItemInput> items)?  $default,) {final _that = this;
switch (_that) {
case _PoInput() when $default != null:
return $default(_that.customerId,_that.orderDate,_that.deliveryDate,_that.notes,_that.discount,_that.tax,_that.shippingCost,_that.dpAmount,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PoInput implements PoInput {
  const _PoInput({required this.customerId, this.orderDate, required this.deliveryDate, this.notes, this.discount, this.tax, this.shippingCost, this.dpAmount, required final  List<PoItemInput> items}): _items = items;
  factory _PoInput.fromJson(Map<String, dynamic> json) => _$PoInputFromJson(json);

@override final  String customerId;
@override final  String? orderDate;
@override final  String deliveryDate;
@override final  String? notes;
@override final  double? discount;
@override final  double? tax;
@override final  double? shippingCost;
@override final  double? dpAmount;
 final  List<PoItemInput> _items;
@override List<PoItemInput> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PoInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoInputCopyWith<_PoInput> get copyWith => __$PoInputCopyWithImpl<_PoInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PoInput&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.orderDate, orderDate) || other.orderDate == orderDate)&&(identical(other.deliveryDate, deliveryDate) || other.deliveryDate == deliveryDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.shippingCost, shippingCost) || other.shippingCost == shippingCost)&&(identical(other.dpAmount, dpAmount) || other.dpAmount == dpAmount)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,customerId,orderDate,deliveryDate,notes,discount,tax,shippingCost,dpAmount,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'PoInput(customerId: $customerId, orderDate: $orderDate, deliveryDate: $deliveryDate, notes: $notes, discount: $discount, tax: $tax, shippingCost: $shippingCost, dpAmount: $dpAmount, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PoInputCopyWith<$Res> implements $PoInputCopyWith<$Res> {
  factory _$PoInputCopyWith(_PoInput value, $Res Function(_PoInput) _then) = __$PoInputCopyWithImpl;
@override @useResult
$Res call({
 String customerId, String? orderDate, String deliveryDate, String? notes, double? discount, double? tax, double? shippingCost, double? dpAmount, List<PoItemInput> items
});




}
/// @nodoc
class __$PoInputCopyWithImpl<$Res>
    implements _$PoInputCopyWith<$Res> {
  __$PoInputCopyWithImpl(this._self, this._then);

  final _PoInput _self;
  final $Res Function(_PoInput) _then;

/// Create a copy of PoInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customerId = null,Object? orderDate = freezed,Object? deliveryDate = null,Object? notes = freezed,Object? discount = freezed,Object? tax = freezed,Object? shippingCost = freezed,Object? dpAmount = freezed,Object? items = null,}) {
  return _then(_PoInput(
customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,orderDate: freezed == orderDate ? _self.orderDate : orderDate // ignore: cast_nullable_to_non_nullable
as String?,deliveryDate: null == deliveryDate ? _self.deliveryDate : deliveryDate // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,tax: freezed == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double?,shippingCost: freezed == shippingCost ? _self.shippingCost : shippingCost // ignore: cast_nullable_to_non_nullable
as double?,dpAmount: freezed == dpAmount ? _self.dpAmount : dpAmount // ignore: cast_nullable_to_non_nullable
as double?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PoItemInput>,
  ));
}


}

// dart format on
