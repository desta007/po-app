// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionStatus {

 String get plan; String get planLabel; bool get isPremium; LatestSubscription? get latestSubscription;
/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStatusCopyWith<SubscriptionStatus> get copyWith => _$SubscriptionStatusCopyWithImpl<SubscriptionStatus>(this as SubscriptionStatus, _$identity);

  /// Serializes this SubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStatus&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.latestSubscription, latestSubscription) || other.latestSubscription == latestSubscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plan,planLabel,isPremium,latestSubscription);

@override
String toString() {
  return 'SubscriptionStatus(plan: $plan, planLabel: $planLabel, isPremium: $isPremium, latestSubscription: $latestSubscription)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStatusCopyWith<$Res>  {
  factory $SubscriptionStatusCopyWith(SubscriptionStatus value, $Res Function(SubscriptionStatus) _then) = _$SubscriptionStatusCopyWithImpl;
@useResult
$Res call({
 String plan, String planLabel, bool isPremium, LatestSubscription? latestSubscription
});


$LatestSubscriptionCopyWith<$Res>? get latestSubscription;

}
/// @nodoc
class _$SubscriptionStatusCopyWithImpl<$Res>
    implements $SubscriptionStatusCopyWith<$Res> {
  _$SubscriptionStatusCopyWithImpl(this._self, this._then);

  final SubscriptionStatus _self;
  final $Res Function(SubscriptionStatus) _then;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? planLabel = null,Object? isPremium = null,Object? latestSubscription = freezed,}) {
  return _then(_self.copyWith(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,latestSubscription: freezed == latestSubscription ? _self.latestSubscription : latestSubscription // ignore: cast_nullable_to_non_nullable
as LatestSubscription?,
  ));
}
/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatestSubscriptionCopyWith<$Res>? get latestSubscription {
    if (_self.latestSubscription == null) {
    return null;
  }

  return $LatestSubscriptionCopyWith<$Res>(_self.latestSubscription!, (value) {
    return _then(_self.copyWith(latestSubscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SubscriptionStatus].
extension SubscriptionStatusPatterns on SubscriptionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plan,  String planLabel,  bool isPremium,  LatestSubscription? latestSubscription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
return $default(_that.plan,_that.planLabel,_that.isPremium,_that.latestSubscription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plan,  String planLabel,  bool isPremium,  LatestSubscription? latestSubscription)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatus():
return $default(_that.plan,_that.planLabel,_that.isPremium,_that.latestSubscription);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plan,  String planLabel,  bool isPremium,  LatestSubscription? latestSubscription)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatus() when $default != null:
return $default(_that.plan,_that.planLabel,_that.isPremium,_that.latestSubscription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionStatus implements SubscriptionStatus {
  const _SubscriptionStatus({this.plan = 'free', this.planLabel = 'Gratis', this.isPremium = false, this.latestSubscription});
  factory _SubscriptionStatus.fromJson(Map<String, dynamic> json) => _$SubscriptionStatusFromJson(json);

@override@JsonKey() final  String plan;
@override@JsonKey() final  String planLabel;
@override@JsonKey() final  bool isPremium;
@override final  LatestSubscription? latestSubscription;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStatusCopyWith<_SubscriptionStatus> get copyWith => __$SubscriptionStatusCopyWithImpl<_SubscriptionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStatus&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.latestSubscription, latestSubscription) || other.latestSubscription == latestSubscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plan,planLabel,isPremium,latestSubscription);

@override
String toString() {
  return 'SubscriptionStatus(plan: $plan, planLabel: $planLabel, isPremium: $isPremium, latestSubscription: $latestSubscription)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStatusCopyWith<$Res> implements $SubscriptionStatusCopyWith<$Res> {
  factory _$SubscriptionStatusCopyWith(_SubscriptionStatus value, $Res Function(_SubscriptionStatus) _then) = __$SubscriptionStatusCopyWithImpl;
@override @useResult
$Res call({
 String plan, String planLabel, bool isPremium, LatestSubscription? latestSubscription
});


@override $LatestSubscriptionCopyWith<$Res>? get latestSubscription;

}
/// @nodoc
class __$SubscriptionStatusCopyWithImpl<$Res>
    implements _$SubscriptionStatusCopyWith<$Res> {
  __$SubscriptionStatusCopyWithImpl(this._self, this._then);

  final _SubscriptionStatus _self;
  final $Res Function(_SubscriptionStatus) _then;

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? planLabel = null,Object? isPremium = null,Object? latestSubscription = freezed,}) {
  return _then(_SubscriptionStatus(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as String,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,latestSubscription: freezed == latestSubscription ? _self.latestSubscription : latestSubscription // ignore: cast_nullable_to_non_nullable
as LatestSubscription?,
  ));
}

/// Create a copy of SubscriptionStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LatestSubscriptionCopyWith<$Res>? get latestSubscription {
    if (_self.latestSubscription == null) {
    return null;
  }

  return $LatestSubscriptionCopyWith<$Res>(_self.latestSubscription!, (value) {
    return _then(_self.copyWith(latestSubscription: value));
  });
}
}


/// @nodoc
mixin _$LatestSubscription {

 String get id; String get status; String? get statusLabel; String? get requestedAt; String? get startsAt; String? get expiresAt; String? get rejectReason;
/// Create a copy of LatestSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LatestSubscriptionCopyWith<LatestSubscription> get copyWith => _$LatestSubscriptionCopyWithImpl<LatestSubscription>(this as LatestSubscription, _$identity);

  /// Serializes this LatestSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LatestSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,statusLabel,requestedAt,startsAt,expiresAt,rejectReason);

@override
String toString() {
  return 'LatestSubscription(id: $id, status: $status, statusLabel: $statusLabel, requestedAt: $requestedAt, startsAt: $startsAt, expiresAt: $expiresAt, rejectReason: $rejectReason)';
}


}

/// @nodoc
abstract mixin class $LatestSubscriptionCopyWith<$Res>  {
  factory $LatestSubscriptionCopyWith(LatestSubscription value, $Res Function(LatestSubscription) _then) = _$LatestSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String status, String? statusLabel, String? requestedAt, String? startsAt, String? expiresAt, String? rejectReason
});




}
/// @nodoc
class _$LatestSubscriptionCopyWithImpl<$Res>
    implements $LatestSubscriptionCopyWith<$Res> {
  _$LatestSubscriptionCopyWithImpl(this._self, this._then);

  final LatestSubscription _self;
  final $Res Function(LatestSubscription) _then;

/// Create a copy of LatestSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? statusLabel = freezed,Object? requestedAt = freezed,Object? startsAt = freezed,Object? expiresAt = freezed,Object? rejectReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LatestSubscription].
extension LatestSubscriptionPatterns on LatestSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LatestSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LatestSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LatestSubscription value)  $default,){
final _that = this;
switch (_that) {
case _LatestSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LatestSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _LatestSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String? statusLabel,  String? requestedAt,  String? startsAt,  String? expiresAt,  String? rejectReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LatestSubscription() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.requestedAt,_that.startsAt,_that.expiresAt,_that.rejectReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String? statusLabel,  String? requestedAt,  String? startsAt,  String? expiresAt,  String? rejectReason)  $default,) {final _that = this;
switch (_that) {
case _LatestSubscription():
return $default(_that.id,_that.status,_that.statusLabel,_that.requestedAt,_that.startsAt,_that.expiresAt,_that.rejectReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String? statusLabel,  String? requestedAt,  String? startsAt,  String? expiresAt,  String? rejectReason)?  $default,) {final _that = this;
switch (_that) {
case _LatestSubscription() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.requestedAt,_that.startsAt,_that.expiresAt,_that.rejectReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LatestSubscription extends LatestSubscription {
  const _LatestSubscription({required this.id, required this.status, this.statusLabel, this.requestedAt, this.startsAt, this.expiresAt, this.rejectReason}): super._();
  factory _LatestSubscription.fromJson(Map<String, dynamic> json) => _$LatestSubscriptionFromJson(json);

@override final  String id;
@override final  String status;
@override final  String? statusLabel;
@override final  String? requestedAt;
@override final  String? startsAt;
@override final  String? expiresAt;
@override final  String? rejectReason;

/// Create a copy of LatestSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LatestSubscriptionCopyWith<_LatestSubscription> get copyWith => __$LatestSubscriptionCopyWithImpl<_LatestSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LatestSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LatestSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,statusLabel,requestedAt,startsAt,expiresAt,rejectReason);

@override
String toString() {
  return 'LatestSubscription(id: $id, status: $status, statusLabel: $statusLabel, requestedAt: $requestedAt, startsAt: $startsAt, expiresAt: $expiresAt, rejectReason: $rejectReason)';
}


}

/// @nodoc
abstract mixin class _$LatestSubscriptionCopyWith<$Res> implements $LatestSubscriptionCopyWith<$Res> {
  factory _$LatestSubscriptionCopyWith(_LatestSubscription value, $Res Function(_LatestSubscription) _then) = __$LatestSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String? statusLabel, String? requestedAt, String? startsAt, String? expiresAt, String? rejectReason
});




}
/// @nodoc
class __$LatestSubscriptionCopyWithImpl<$Res>
    implements _$LatestSubscriptionCopyWith<$Res> {
  __$LatestSubscriptionCopyWithImpl(this._self, this._then);

  final _LatestSubscription _self;
  final $Res Function(_LatestSubscription) _then;

/// Create a copy of LatestSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? statusLabel = freezed,Object? requestedAt = freezed,Object? startsAt = freezed,Object? expiresAt = freezed,Object? rejectReason = freezed,}) {
  return _then(_LatestSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as String?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$QuotaItem {

 int get current; int? get limit;
/// Create a copy of QuotaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<QuotaItem> get copyWith => _$QuotaItemCopyWithImpl<QuotaItem>(this as QuotaItem, _$identity);

  /// Serializes this QuotaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotaItem&&(identical(other.current, current) || other.current == current)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,limit);

@override
String toString() {
  return 'QuotaItem(current: $current, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $QuotaItemCopyWith<$Res>  {
  factory $QuotaItemCopyWith(QuotaItem value, $Res Function(QuotaItem) _then) = _$QuotaItemCopyWithImpl;
@useResult
$Res call({
 int current, int? limit
});




}
/// @nodoc
class _$QuotaItemCopyWithImpl<$Res>
    implements $QuotaItemCopyWith<$Res> {
  _$QuotaItemCopyWithImpl(this._self, this._then);

  final QuotaItem _self;
  final $Res Function(QuotaItem) _then;

/// Create a copy of QuotaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? limit = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuotaItem].
extension QuotaItemPatterns on QuotaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotaItem value)  $default,){
final _that = this;
switch (_that) {
case _QuotaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotaItem value)?  $default,){
final _that = this;
switch (_that) {
case _QuotaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int? limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotaItem() when $default != null:
return $default(_that.current,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int? limit)  $default,) {final _that = this;
switch (_that) {
case _QuotaItem():
return $default(_that.current,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int? limit)?  $default,) {final _that = this;
switch (_that) {
case _QuotaItem() when $default != null:
return $default(_that.current,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuotaItem extends QuotaItem {
  const _QuotaItem({this.current = 0, this.limit}): super._();
  factory _QuotaItem.fromJson(Map<String, dynamic> json) => _$QuotaItemFromJson(json);

@override@JsonKey() final  int current;
@override final  int? limit;

/// Create a copy of QuotaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotaItemCopyWith<_QuotaItem> get copyWith => __$QuotaItemCopyWithImpl<_QuotaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuotaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotaItem&&(identical(other.current, current) || other.current == current)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,limit);

@override
String toString() {
  return 'QuotaItem(current: $current, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$QuotaItemCopyWith<$Res> implements $QuotaItemCopyWith<$Res> {
  factory _$QuotaItemCopyWith(_QuotaItem value, $Res Function(_QuotaItem) _then) = __$QuotaItemCopyWithImpl;
@override @useResult
$Res call({
 int current, int? limit
});




}
/// @nodoc
class __$QuotaItemCopyWithImpl<$Res>
    implements _$QuotaItemCopyWith<$Res> {
  __$QuotaItemCopyWithImpl(this._self, this._then);

  final _QuotaItem _self;
  final $Res Function(_QuotaItem) _then;

/// Create a copy of QuotaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? limit = freezed,}) {
  return _then(_QuotaItem(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$QuotaUsage {

 bool get isPremium; QuotaItem get poMonthly; QuotaItem get products; QuotaItem get teamMembers;
/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuotaUsageCopyWith<QuotaUsage> get copyWith => _$QuotaUsageCopyWithImpl<QuotaUsage>(this as QuotaUsage, _$identity);

  /// Serializes this QuotaUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuotaUsage&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.poMonthly, poMonthly) || other.poMonthly == poMonthly)&&(identical(other.products, products) || other.products == products)&&(identical(other.teamMembers, teamMembers) || other.teamMembers == teamMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPremium,poMonthly,products,teamMembers);

@override
String toString() {
  return 'QuotaUsage(isPremium: $isPremium, poMonthly: $poMonthly, products: $products, teamMembers: $teamMembers)';
}


}

/// @nodoc
abstract mixin class $QuotaUsageCopyWith<$Res>  {
  factory $QuotaUsageCopyWith(QuotaUsage value, $Res Function(QuotaUsage) _then) = _$QuotaUsageCopyWithImpl;
@useResult
$Res call({
 bool isPremium, QuotaItem poMonthly, QuotaItem products, QuotaItem teamMembers
});


$QuotaItemCopyWith<$Res> get poMonthly;$QuotaItemCopyWith<$Res> get products;$QuotaItemCopyWith<$Res> get teamMembers;

}
/// @nodoc
class _$QuotaUsageCopyWithImpl<$Res>
    implements $QuotaUsageCopyWith<$Res> {
  _$QuotaUsageCopyWithImpl(this._self, this._then);

  final QuotaUsage _self;
  final $Res Function(QuotaUsage) _then;

/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPremium = null,Object? poMonthly = null,Object? products = null,Object? teamMembers = null,}) {
  return _then(_self.copyWith(
isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,poMonthly: null == poMonthly ? _self.poMonthly : poMonthly // ignore: cast_nullable_to_non_nullable
as QuotaItem,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as QuotaItem,teamMembers: null == teamMembers ? _self.teamMembers : teamMembers // ignore: cast_nullable_to_non_nullable
as QuotaItem,
  ));
}
/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get poMonthly {
  
  return $QuotaItemCopyWith<$Res>(_self.poMonthly, (value) {
    return _then(_self.copyWith(poMonthly: value));
  });
}/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get products {
  
  return $QuotaItemCopyWith<$Res>(_self.products, (value) {
    return _then(_self.copyWith(products: value));
  });
}/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get teamMembers {
  
  return $QuotaItemCopyWith<$Res>(_self.teamMembers, (value) {
    return _then(_self.copyWith(teamMembers: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuotaUsage].
extension QuotaUsagePatterns on QuotaUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuotaUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuotaUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuotaUsage value)  $default,){
final _that = this;
switch (_that) {
case _QuotaUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuotaUsage value)?  $default,){
final _that = this;
switch (_that) {
case _QuotaUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPremium,  QuotaItem poMonthly,  QuotaItem products,  QuotaItem teamMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuotaUsage() when $default != null:
return $default(_that.isPremium,_that.poMonthly,_that.products,_that.teamMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPremium,  QuotaItem poMonthly,  QuotaItem products,  QuotaItem teamMembers)  $default,) {final _that = this;
switch (_that) {
case _QuotaUsage():
return $default(_that.isPremium,_that.poMonthly,_that.products,_that.teamMembers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPremium,  QuotaItem poMonthly,  QuotaItem products,  QuotaItem teamMembers)?  $default,) {final _that = this;
switch (_that) {
case _QuotaUsage() when $default != null:
return $default(_that.isPremium,_that.poMonthly,_that.products,_that.teamMembers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuotaUsage implements QuotaUsage {
  const _QuotaUsage({this.isPremium = false, this.poMonthly = const QuotaItem(), this.products = const QuotaItem(), this.teamMembers = const QuotaItem()});
  factory _QuotaUsage.fromJson(Map<String, dynamic> json) => _$QuotaUsageFromJson(json);

@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  QuotaItem poMonthly;
@override@JsonKey() final  QuotaItem products;
@override@JsonKey() final  QuotaItem teamMembers;

/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuotaUsageCopyWith<_QuotaUsage> get copyWith => __$QuotaUsageCopyWithImpl<_QuotaUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuotaUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuotaUsage&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.poMonthly, poMonthly) || other.poMonthly == poMonthly)&&(identical(other.products, products) || other.products == products)&&(identical(other.teamMembers, teamMembers) || other.teamMembers == teamMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPremium,poMonthly,products,teamMembers);

@override
String toString() {
  return 'QuotaUsage(isPremium: $isPremium, poMonthly: $poMonthly, products: $products, teamMembers: $teamMembers)';
}


}

/// @nodoc
abstract mixin class _$QuotaUsageCopyWith<$Res> implements $QuotaUsageCopyWith<$Res> {
  factory _$QuotaUsageCopyWith(_QuotaUsage value, $Res Function(_QuotaUsage) _then) = __$QuotaUsageCopyWithImpl;
@override @useResult
$Res call({
 bool isPremium, QuotaItem poMonthly, QuotaItem products, QuotaItem teamMembers
});


@override $QuotaItemCopyWith<$Res> get poMonthly;@override $QuotaItemCopyWith<$Res> get products;@override $QuotaItemCopyWith<$Res> get teamMembers;

}
/// @nodoc
class __$QuotaUsageCopyWithImpl<$Res>
    implements _$QuotaUsageCopyWith<$Res> {
  __$QuotaUsageCopyWithImpl(this._self, this._then);

  final _QuotaUsage _self;
  final $Res Function(_QuotaUsage) _then;

/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPremium = null,Object? poMonthly = null,Object? products = null,Object? teamMembers = null,}) {
  return _then(_QuotaUsage(
isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,poMonthly: null == poMonthly ? _self.poMonthly : poMonthly // ignore: cast_nullable_to_non_nullable
as QuotaItem,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as QuotaItem,teamMembers: null == teamMembers ? _self.teamMembers : teamMembers // ignore: cast_nullable_to_non_nullable
as QuotaItem,
  ));
}

/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get poMonthly {
  
  return $QuotaItemCopyWith<$Res>(_self.poMonthly, (value) {
    return _then(_self.copyWith(poMonthly: value));
  });
}/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get products {
  
  return $QuotaItemCopyWith<$Res>(_self.products, (value) {
    return _then(_self.copyWith(products: value));
  });
}/// Create a copy of QuotaUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuotaItemCopyWith<$Res> get teamMembers {
  
  return $QuotaItemCopyWith<$Res>(_self.teamMembers, (value) {
    return _then(_self.copyWith(teamMembers: value));
  });
}
}

// dart format on
