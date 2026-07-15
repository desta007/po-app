// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarEvent {

 String get id; String get title; String get start;@JsonKey(name: 'extendedProps') CalendarEventProps get props;
/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventCopyWith<CalendarEvent> get copyWith => _$CalendarEventCopyWithImpl<CalendarEvent>(this as CalendarEvent, _$identity);

  /// Serializes this CalendarEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.start, start) || other.start == start)&&(identical(other.props, props) || other.props == props));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,start,props);

@override
String toString() {
  return 'CalendarEvent(id: $id, title: $title, start: $start, props: $props)';
}


}

/// @nodoc
abstract mixin class $CalendarEventCopyWith<$Res>  {
  factory $CalendarEventCopyWith(CalendarEvent value, $Res Function(CalendarEvent) _then) = _$CalendarEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String start,@JsonKey(name: 'extendedProps') CalendarEventProps props
});


$CalendarEventPropsCopyWith<$Res> get props;

}
/// @nodoc
class _$CalendarEventCopyWithImpl<$Res>
    implements $CalendarEventCopyWith<$Res> {
  _$CalendarEventCopyWithImpl(this._self, this._then);

  final CalendarEvent _self;
  final $Res Function(CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? start = null,Object? props = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as CalendarEventProps,
  ));
}
/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarEventPropsCopyWith<$Res> get props {
  
  return $CalendarEventPropsCopyWith<$Res>(_self.props, (value) {
    return _then(_self.copyWith(props: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalendarEvent].
extension CalendarEventPatterns on CalendarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEvent value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String start, @JsonKey(name: 'extendedProps')  CalendarEventProps props)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.props);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String start, @JsonKey(name: 'extendedProps')  CalendarEventProps props)  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent():
return $default(_that.id,_that.title,_that.start,_that.props);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String start, @JsonKey(name: 'extendedProps')  CalendarEventProps props)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEvent() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.props);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEvent implements CalendarEvent {
  const _CalendarEvent({required this.id, required this.title, required this.start, @JsonKey(name: 'extendedProps') required this.props});
  factory _CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String start;
@override@JsonKey(name: 'extendedProps') final  CalendarEventProps props;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventCopyWith<_CalendarEvent> get copyWith => __$CalendarEventCopyWithImpl<_CalendarEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.start, start) || other.start == start)&&(identical(other.props, props) || other.props == props));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,start,props);

@override
String toString() {
  return 'CalendarEvent(id: $id, title: $title, start: $start, props: $props)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventCopyWith<$Res> implements $CalendarEventCopyWith<$Res> {
  factory _$CalendarEventCopyWith(_CalendarEvent value, $Res Function(_CalendarEvent) _then) = __$CalendarEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String start,@JsonKey(name: 'extendedProps') CalendarEventProps props
});


@override $CalendarEventPropsCopyWith<$Res> get props;

}
/// @nodoc
class __$CalendarEventCopyWithImpl<$Res>
    implements _$CalendarEventCopyWith<$Res> {
  __$CalendarEventCopyWithImpl(this._self, this._then);

  final _CalendarEvent _self;
  final $Res Function(_CalendarEvent) _then;

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? start = null,Object? props = null,}) {
  return _then(_CalendarEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as CalendarEventProps,
  ));
}

/// Create a copy of CalendarEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarEventPropsCopyWith<$Res> get props {
  
  return $CalendarEventPropsCopyWith<$Res>(_self.props, (value) {
    return _then(_self.copyWith(props: value));
  });
}
}


/// @nodoc
mixin _$CalendarEventProps {

 String get poNumber; String get customerName;@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus get status;@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus get paymentStatus;@FlexDouble() double get total;
/// Create a copy of CalendarEventProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarEventPropsCopyWith<CalendarEventProps> get copyWith => _$CalendarEventPropsCopyWithImpl<CalendarEventProps>(this as CalendarEventProps, _$identity);

  /// Serializes this CalendarEventProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarEventProps&&(identical(other.poNumber, poNumber) || other.poNumber == poNumber)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,poNumber,customerName,status,paymentStatus,total);

@override
String toString() {
  return 'CalendarEventProps(poNumber: $poNumber, customerName: $customerName, status: $status, paymentStatus: $paymentStatus, total: $total)';
}


}

/// @nodoc
abstract mixin class $CalendarEventPropsCopyWith<$Res>  {
  factory $CalendarEventPropsCopyWith(CalendarEventProps value, $Res Function(CalendarEventProps) _then) = _$CalendarEventPropsCopyWithImpl;
@useResult
$Res call({
 String poNumber, String customerName,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus status,@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus paymentStatus,@FlexDouble() double total
});




}
/// @nodoc
class _$CalendarEventPropsCopyWithImpl<$Res>
    implements $CalendarEventPropsCopyWith<$Res> {
  _$CalendarEventPropsCopyWithImpl(this._self, this._then);

  final CalendarEventProps _self;
  final $Res Function(CalendarEventProps) _then;

/// Create a copy of CalendarEventProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? poNumber = null,Object? customerName = null,Object? status = null,Object? paymentStatus = null,Object? total = null,}) {
  return _then(_self.copyWith(
poNumber: null == poNumber ? _self.poNumber : poNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarEventProps].
extension CalendarEventPropsPatterns on CalendarEventProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarEventProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarEventProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarEventProps value)  $default,){
final _that = this;
switch (_that) {
case _CalendarEventProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarEventProps value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarEventProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String poNumber,  String customerName, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarEventProps() when $default != null:
return $default(_that.poNumber,_that.customerName,_that.status,_that.paymentStatus,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String poNumber,  String customerName, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double total)  $default,) {final _that = this;
switch (_that) {
case _CalendarEventProps():
return $default(_that.poNumber,_that.customerName,_that.status,_that.paymentStatus,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String poNumber,  String customerName, @JsonKey(unknownEnumValue: PoStatus.draft)  PoStatus status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid)  PaymentStatus paymentStatus, @FlexDouble()  double total)?  $default,) {final _that = this;
switch (_that) {
case _CalendarEventProps() when $default != null:
return $default(_that.poNumber,_that.customerName,_that.status,_that.paymentStatus,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarEventProps implements CalendarEventProps {
  const _CalendarEventProps({required this.poNumber, required this.customerName, @JsonKey(unknownEnumValue: PoStatus.draft) required this.status, @JsonKey(unknownEnumValue: PaymentStatus.unpaid) required this.paymentStatus, @FlexDouble() this.total = 0});
  factory _CalendarEventProps.fromJson(Map<String, dynamic> json) => _$CalendarEventPropsFromJson(json);

@override final  String poNumber;
@override final  String customerName;
@override@JsonKey(unknownEnumValue: PoStatus.draft) final  PoStatus status;
@override@JsonKey(unknownEnumValue: PaymentStatus.unpaid) final  PaymentStatus paymentStatus;
@override@JsonKey()@FlexDouble() final  double total;

/// Create a copy of CalendarEventProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarEventPropsCopyWith<_CalendarEventProps> get copyWith => __$CalendarEventPropsCopyWithImpl<_CalendarEventProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarEventPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarEventProps&&(identical(other.poNumber, poNumber) || other.poNumber == poNumber)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,poNumber,customerName,status,paymentStatus,total);

@override
String toString() {
  return 'CalendarEventProps(poNumber: $poNumber, customerName: $customerName, status: $status, paymentStatus: $paymentStatus, total: $total)';
}


}

/// @nodoc
abstract mixin class _$CalendarEventPropsCopyWith<$Res> implements $CalendarEventPropsCopyWith<$Res> {
  factory _$CalendarEventPropsCopyWith(_CalendarEventProps value, $Res Function(_CalendarEventProps) _then) = __$CalendarEventPropsCopyWithImpl;
@override @useResult
$Res call({
 String poNumber, String customerName,@JsonKey(unknownEnumValue: PoStatus.draft) PoStatus status,@JsonKey(unknownEnumValue: PaymentStatus.unpaid) PaymentStatus paymentStatus,@FlexDouble() double total
});




}
/// @nodoc
class __$CalendarEventPropsCopyWithImpl<$Res>
    implements _$CalendarEventPropsCopyWith<$Res> {
  __$CalendarEventPropsCopyWithImpl(this._self, this._then);

  final _CalendarEventProps _self;
  final $Res Function(_CalendarEventProps) _then;

/// Create a copy of CalendarEventProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? poNumber = null,Object? customerName = null,Object? status = null,Object? paymentStatus = null,Object? total = null,}) {
  return _then(_CalendarEventProps(
poNumber: null == poNumber ? _self.poNumber : poNumber // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PoStatus,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
