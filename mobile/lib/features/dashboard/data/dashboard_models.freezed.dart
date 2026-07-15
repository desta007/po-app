// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodaySummary {

@FlexInt() int get totalPo; String? get poChange; bool get poChangeUp;@FlexDouble() double get totalRevenue; String? get revenueChange; bool get revenueChangeUp;@FlexInt() int get activeCustomers; String? get customerChange;@FlexInt() int get totalOrdersThisMonth;@FlexInt() int get draft;@FlexInt() int get confirmed;@FlexInt() int get inProgress;@FlexInt() int get completed;
/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodaySummaryCopyWith<TodaySummary> get copyWith => _$TodaySummaryCopyWithImpl<TodaySummary>(this as TodaySummary, _$identity);

  /// Serializes this TodaySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodaySummary&&(identical(other.totalPo, totalPo) || other.totalPo == totalPo)&&(identical(other.poChange, poChange) || other.poChange == poChange)&&(identical(other.poChangeUp, poChangeUp) || other.poChangeUp == poChangeUp)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.revenueChange, revenueChange) || other.revenueChange == revenueChange)&&(identical(other.revenueChangeUp, revenueChangeUp) || other.revenueChangeUp == revenueChangeUp)&&(identical(other.activeCustomers, activeCustomers) || other.activeCustomers == activeCustomers)&&(identical(other.customerChange, customerChange) || other.customerChange == customerChange)&&(identical(other.totalOrdersThisMonth, totalOrdersThisMonth) || other.totalOrdersThisMonth == totalOrdersThisMonth)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalPo,poChange,poChangeUp,totalRevenue,revenueChange,revenueChangeUp,activeCustomers,customerChange,totalOrdersThisMonth,draft,confirmed,inProgress,completed);

@override
String toString() {
  return 'TodaySummary(totalPo: $totalPo, poChange: $poChange, poChangeUp: $poChangeUp, totalRevenue: $totalRevenue, revenueChange: $revenueChange, revenueChangeUp: $revenueChangeUp, activeCustomers: $activeCustomers, customerChange: $customerChange, totalOrdersThisMonth: $totalOrdersThisMonth, draft: $draft, confirmed: $confirmed, inProgress: $inProgress, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $TodaySummaryCopyWith<$Res>  {
  factory $TodaySummaryCopyWith(TodaySummary value, $Res Function(TodaySummary) _then) = _$TodaySummaryCopyWithImpl;
@useResult
$Res call({
@FlexInt() int totalPo, String? poChange, bool poChangeUp,@FlexDouble() double totalRevenue, String? revenueChange, bool revenueChangeUp,@FlexInt() int activeCustomers, String? customerChange,@FlexInt() int totalOrdersThisMonth,@FlexInt() int draft,@FlexInt() int confirmed,@FlexInt() int inProgress,@FlexInt() int completed
});




}
/// @nodoc
class _$TodaySummaryCopyWithImpl<$Res>
    implements $TodaySummaryCopyWith<$Res> {
  _$TodaySummaryCopyWithImpl(this._self, this._then);

  final TodaySummary _self;
  final $Res Function(TodaySummary) _then;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPo = null,Object? poChange = freezed,Object? poChangeUp = null,Object? totalRevenue = null,Object? revenueChange = freezed,Object? revenueChangeUp = null,Object? activeCustomers = null,Object? customerChange = freezed,Object? totalOrdersThisMonth = null,Object? draft = null,Object? confirmed = null,Object? inProgress = null,Object? completed = null,}) {
  return _then(_self.copyWith(
totalPo: null == totalPo ? _self.totalPo : totalPo // ignore: cast_nullable_to_non_nullable
as int,poChange: freezed == poChange ? _self.poChange : poChange // ignore: cast_nullable_to_non_nullable
as String?,poChangeUp: null == poChangeUp ? _self.poChangeUp : poChangeUp // ignore: cast_nullable_to_non_nullable
as bool,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueChange: freezed == revenueChange ? _self.revenueChange : revenueChange // ignore: cast_nullable_to_non_nullable
as String?,revenueChangeUp: null == revenueChangeUp ? _self.revenueChangeUp : revenueChangeUp // ignore: cast_nullable_to_non_nullable
as bool,activeCustomers: null == activeCustomers ? _self.activeCustomers : activeCustomers // ignore: cast_nullable_to_non_nullable
as int,customerChange: freezed == customerChange ? _self.customerChange : customerChange // ignore: cast_nullable_to_non_nullable
as String?,totalOrdersThisMonth: null == totalOrdersThisMonth ? _self.totalOrdersThisMonth : totalOrdersThisMonth // ignore: cast_nullable_to_non_nullable
as int,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TodaySummary].
extension TodaySummaryPatterns on TodaySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodaySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodaySummary value)  $default,){
final _that = this;
switch (_that) {
case _TodaySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodaySummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@FlexInt()  int totalPo,  String? poChange,  bool poChangeUp, @FlexDouble()  double totalRevenue,  String? revenueChange,  bool revenueChangeUp, @FlexInt()  int activeCustomers,  String? customerChange, @FlexInt()  int totalOrdersThisMonth, @FlexInt()  int draft, @FlexInt()  int confirmed, @FlexInt()  int inProgress, @FlexInt()  int completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
return $default(_that.totalPo,_that.poChange,_that.poChangeUp,_that.totalRevenue,_that.revenueChange,_that.revenueChangeUp,_that.activeCustomers,_that.customerChange,_that.totalOrdersThisMonth,_that.draft,_that.confirmed,_that.inProgress,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@FlexInt()  int totalPo,  String? poChange,  bool poChangeUp, @FlexDouble()  double totalRevenue,  String? revenueChange,  bool revenueChangeUp, @FlexInt()  int activeCustomers,  String? customerChange, @FlexInt()  int totalOrdersThisMonth, @FlexInt()  int draft, @FlexInt()  int confirmed, @FlexInt()  int inProgress, @FlexInt()  int completed)  $default,) {final _that = this;
switch (_that) {
case _TodaySummary():
return $default(_that.totalPo,_that.poChange,_that.poChangeUp,_that.totalRevenue,_that.revenueChange,_that.revenueChangeUp,_that.activeCustomers,_that.customerChange,_that.totalOrdersThisMonth,_that.draft,_that.confirmed,_that.inProgress,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@FlexInt()  int totalPo,  String? poChange,  bool poChangeUp, @FlexDouble()  double totalRevenue,  String? revenueChange,  bool revenueChangeUp, @FlexInt()  int activeCustomers,  String? customerChange, @FlexInt()  int totalOrdersThisMonth, @FlexInt()  int draft, @FlexInt()  int confirmed, @FlexInt()  int inProgress, @FlexInt()  int completed)?  $default,) {final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
return $default(_that.totalPo,_that.poChange,_that.poChangeUp,_that.totalRevenue,_that.revenueChange,_that.revenueChangeUp,_that.activeCustomers,_that.customerChange,_that.totalOrdersThisMonth,_that.draft,_that.confirmed,_that.inProgress,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodaySummary implements TodaySummary {
  const _TodaySummary({@FlexInt() this.totalPo = 0, this.poChange, this.poChangeUp = true, @FlexDouble() this.totalRevenue = 0, this.revenueChange, this.revenueChangeUp = true, @FlexInt() this.activeCustomers = 0, this.customerChange, @FlexInt() this.totalOrdersThisMonth = 0, @FlexInt() this.draft = 0, @FlexInt() this.confirmed = 0, @FlexInt() this.inProgress = 0, @FlexInt() this.completed = 0});
  factory _TodaySummary.fromJson(Map<String, dynamic> json) => _$TodaySummaryFromJson(json);

@override@JsonKey()@FlexInt() final  int totalPo;
@override final  String? poChange;
@override@JsonKey() final  bool poChangeUp;
@override@JsonKey()@FlexDouble() final  double totalRevenue;
@override final  String? revenueChange;
@override@JsonKey() final  bool revenueChangeUp;
@override@JsonKey()@FlexInt() final  int activeCustomers;
@override final  String? customerChange;
@override@JsonKey()@FlexInt() final  int totalOrdersThisMonth;
@override@JsonKey()@FlexInt() final  int draft;
@override@JsonKey()@FlexInt() final  int confirmed;
@override@JsonKey()@FlexInt() final  int inProgress;
@override@JsonKey()@FlexInt() final  int completed;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodaySummaryCopyWith<_TodaySummary> get copyWith => __$TodaySummaryCopyWithImpl<_TodaySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodaySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodaySummary&&(identical(other.totalPo, totalPo) || other.totalPo == totalPo)&&(identical(other.poChange, poChange) || other.poChange == poChange)&&(identical(other.poChangeUp, poChangeUp) || other.poChangeUp == poChangeUp)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.revenueChange, revenueChange) || other.revenueChange == revenueChange)&&(identical(other.revenueChangeUp, revenueChangeUp) || other.revenueChangeUp == revenueChangeUp)&&(identical(other.activeCustomers, activeCustomers) || other.activeCustomers == activeCustomers)&&(identical(other.customerChange, customerChange) || other.customerChange == customerChange)&&(identical(other.totalOrdersThisMonth, totalOrdersThisMonth) || other.totalOrdersThisMonth == totalOrdersThisMonth)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalPo,poChange,poChangeUp,totalRevenue,revenueChange,revenueChangeUp,activeCustomers,customerChange,totalOrdersThisMonth,draft,confirmed,inProgress,completed);

@override
String toString() {
  return 'TodaySummary(totalPo: $totalPo, poChange: $poChange, poChangeUp: $poChangeUp, totalRevenue: $totalRevenue, revenueChange: $revenueChange, revenueChangeUp: $revenueChangeUp, activeCustomers: $activeCustomers, customerChange: $customerChange, totalOrdersThisMonth: $totalOrdersThisMonth, draft: $draft, confirmed: $confirmed, inProgress: $inProgress, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$TodaySummaryCopyWith<$Res> implements $TodaySummaryCopyWith<$Res> {
  factory _$TodaySummaryCopyWith(_TodaySummary value, $Res Function(_TodaySummary) _then) = __$TodaySummaryCopyWithImpl;
@override @useResult
$Res call({
@FlexInt() int totalPo, String? poChange, bool poChangeUp,@FlexDouble() double totalRevenue, String? revenueChange, bool revenueChangeUp,@FlexInt() int activeCustomers, String? customerChange,@FlexInt() int totalOrdersThisMonth,@FlexInt() int draft,@FlexInt() int confirmed,@FlexInt() int inProgress,@FlexInt() int completed
});




}
/// @nodoc
class __$TodaySummaryCopyWithImpl<$Res>
    implements _$TodaySummaryCopyWith<$Res> {
  __$TodaySummaryCopyWithImpl(this._self, this._then);

  final _TodaySummary _self;
  final $Res Function(_TodaySummary) _then;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPo = null,Object? poChange = freezed,Object? poChangeUp = null,Object? totalRevenue = null,Object? revenueChange = freezed,Object? revenueChangeUp = null,Object? activeCustomers = null,Object? customerChange = freezed,Object? totalOrdersThisMonth = null,Object? draft = null,Object? confirmed = null,Object? inProgress = null,Object? completed = null,}) {
  return _then(_TodaySummary(
totalPo: null == totalPo ? _self.totalPo : totalPo // ignore: cast_nullable_to_non_nullable
as int,poChange: freezed == poChange ? _self.poChange : poChange // ignore: cast_nullable_to_non_nullable
as String?,poChangeUp: null == poChangeUp ? _self.poChangeUp : poChangeUp // ignore: cast_nullable_to_non_nullable
as bool,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,revenueChange: freezed == revenueChange ? _self.revenueChange : revenueChange // ignore: cast_nullable_to_non_nullable
as String?,revenueChangeUp: null == revenueChangeUp ? _self.revenueChangeUp : revenueChangeUp // ignore: cast_nullable_to_non_nullable
as bool,activeCustomers: null == activeCustomers ? _self.activeCustomers : activeCustomers // ignore: cast_nullable_to_non_nullable
as int,customerChange: freezed == customerChange ? _self.customerChange : customerChange // ignore: cast_nullable_to_non_nullable
as String?,totalOrdersThisMonth: null == totalOrdersThisMonth ? _self.totalOrdersThisMonth : totalOrdersThisMonth // ignore: cast_nullable_to_non_nullable
as int,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RevenueDataPoint {

 String get date;@FlexDouble() double get revenue;@FlexInt() int get count;
/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueDataPointCopyWith<RevenueDataPoint> get copyWith => _$RevenueDataPointCopyWithImpl<RevenueDataPoint>(this as RevenueDataPoint, _$identity);

  /// Serializes this RevenueDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,count);

@override
String toString() {
  return 'RevenueDataPoint(date: $date, revenue: $revenue, count: $count)';
}


}

/// @nodoc
abstract mixin class $RevenueDataPointCopyWith<$Res>  {
  factory $RevenueDataPointCopyWith(RevenueDataPoint value, $Res Function(RevenueDataPoint) _then) = _$RevenueDataPointCopyWithImpl;
@useResult
$Res call({
 String date,@FlexDouble() double revenue,@FlexInt() int count
});




}
/// @nodoc
class _$RevenueDataPointCopyWithImpl<$Res>
    implements $RevenueDataPointCopyWith<$Res> {
  _$RevenueDataPointCopyWithImpl(this._self, this._then);

  final RevenueDataPoint _self;
  final $Res Function(RevenueDataPoint) _then;

/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? revenue = null,Object? count = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueDataPoint].
extension RevenueDataPointPatterns on RevenueDataPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _RevenueDataPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @FlexDouble()  double revenue, @FlexInt()  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @FlexDouble()  double revenue, @FlexInt()  int count)  $default,) {final _that = this;
switch (_that) {
case _RevenueDataPoint():
return $default(_that.date,_that.revenue,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @FlexDouble()  double revenue, @FlexInt()  int count)?  $default,) {final _that = this;
switch (_that) {
case _RevenueDataPoint() when $default != null:
return $default(_that.date,_that.revenue,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueDataPoint implements RevenueDataPoint {
  const _RevenueDataPoint({required this.date, @FlexDouble() this.revenue = 0, @FlexInt() this.count = 0});
  factory _RevenueDataPoint.fromJson(Map<String, dynamic> json) => _$RevenueDataPointFromJson(json);

@override final  String date;
@override@JsonKey()@FlexDouble() final  double revenue;
@override@JsonKey()@FlexInt() final  int count;

/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueDataPointCopyWith<_RevenueDataPoint> get copyWith => __$RevenueDataPointCopyWithImpl<_RevenueDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueDataPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,revenue,count);

@override
String toString() {
  return 'RevenueDataPoint(date: $date, revenue: $revenue, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RevenueDataPointCopyWith<$Res> implements $RevenueDataPointCopyWith<$Res> {
  factory _$RevenueDataPointCopyWith(_RevenueDataPoint value, $Res Function(_RevenueDataPoint) _then) = __$RevenueDataPointCopyWithImpl;
@override @useResult
$Res call({
 String date,@FlexDouble() double revenue,@FlexInt() int count
});




}
/// @nodoc
class __$RevenueDataPointCopyWithImpl<$Res>
    implements _$RevenueDataPointCopyWith<$Res> {
  __$RevenueDataPointCopyWithImpl(this._self, this._then);

  final _RevenueDataPoint _self;
  final $Res Function(_RevenueDataPoint) _then;

/// Create a copy of RevenueDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? revenue = null,Object? count = null,}) {
  return _then(_RevenueDataPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TopCustomer {

 String? get id; String get name;@FlexDouble() double get totalRevenue;@FlexInt() int get totalOrders;
/// Create a copy of TopCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopCustomerCopyWith<TopCustomer> get copyWith => _$TopCustomerCopyWithImpl<TopCustomer>(this as TopCustomer, _$identity);

  /// Serializes this TopCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,totalRevenue,totalOrders);

@override
String toString() {
  return 'TopCustomer(id: $id, name: $name, totalRevenue: $totalRevenue, totalOrders: $totalOrders)';
}


}

/// @nodoc
abstract mixin class $TopCustomerCopyWith<$Res>  {
  factory $TopCustomerCopyWith(TopCustomer value, $Res Function(TopCustomer) _then) = _$TopCustomerCopyWithImpl;
@useResult
$Res call({
 String? id, String name,@FlexDouble() double totalRevenue,@FlexInt() int totalOrders
});




}
/// @nodoc
class _$TopCustomerCopyWithImpl<$Res>
    implements $TopCustomerCopyWith<$Res> {
  _$TopCustomerCopyWithImpl(this._self, this._then);

  final TopCustomer _self;
  final $Res Function(TopCustomer) _then;

/// Create a copy of TopCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? totalRevenue = null,Object? totalOrders = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TopCustomer].
extension TopCustomerPatterns on TopCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopCustomer value)  $default,){
final _that = this;
switch (_that) {
case _TopCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _TopCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name, @FlexDouble()  double totalRevenue, @FlexInt()  int totalOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopCustomer() when $default != null:
return $default(_that.id,_that.name,_that.totalRevenue,_that.totalOrders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name, @FlexDouble()  double totalRevenue, @FlexInt()  int totalOrders)  $default,) {final _that = this;
switch (_that) {
case _TopCustomer():
return $default(_that.id,_that.name,_that.totalRevenue,_that.totalOrders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name, @FlexDouble()  double totalRevenue, @FlexInt()  int totalOrders)?  $default,) {final _that = this;
switch (_that) {
case _TopCustomer() when $default != null:
return $default(_that.id,_that.name,_that.totalRevenue,_that.totalOrders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopCustomer implements TopCustomer {
  const _TopCustomer({this.id, required this.name, @FlexDouble() this.totalRevenue = 0, @FlexInt() this.totalOrders = 0});
  factory _TopCustomer.fromJson(Map<String, dynamic> json) => _$TopCustomerFromJson(json);

@override final  String? id;
@override final  String name;
@override@JsonKey()@FlexDouble() final  double totalRevenue;
@override@JsonKey()@FlexInt() final  int totalOrders;

/// Create a copy of TopCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopCustomerCopyWith<_TopCustomer> get copyWith => __$TopCustomerCopyWithImpl<_TopCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,totalRevenue,totalOrders);

@override
String toString() {
  return 'TopCustomer(id: $id, name: $name, totalRevenue: $totalRevenue, totalOrders: $totalOrders)';
}


}

/// @nodoc
abstract mixin class _$TopCustomerCopyWith<$Res> implements $TopCustomerCopyWith<$Res> {
  factory _$TopCustomerCopyWith(_TopCustomer value, $Res Function(_TopCustomer) _then) = __$TopCustomerCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name,@FlexDouble() double totalRevenue,@FlexInt() int totalOrders
});




}
/// @nodoc
class __$TopCustomerCopyWithImpl<$Res>
    implements _$TopCustomerCopyWith<$Res> {
  __$TopCustomerCopyWithImpl(this._self, this._then);

  final _TopCustomer _self;
  final $Res Function(_TopCustomer) _then;

/// Create a copy of TopCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? totalRevenue = null,Object? totalOrders = null,}) {
  return _then(_TopCustomer(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TopProduct {

 String? get id; String get name;@FlexDouble() double get totalQty;@FlexDouble() double get totalRevenue;
/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopProductCopyWith<TopProduct> get copyWith => _$TopProductCopyWithImpl<TopProduct>(this as TopProduct, _$identity);

  /// Serializes this TopProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.totalQty, totalQty) || other.totalQty == totalQty)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,totalQty,totalRevenue);

@override
String toString() {
  return 'TopProduct(id: $id, name: $name, totalQty: $totalQty, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class $TopProductCopyWith<$Res>  {
  factory $TopProductCopyWith(TopProduct value, $Res Function(TopProduct) _then) = _$TopProductCopyWithImpl;
@useResult
$Res call({
 String? id, String name,@FlexDouble() double totalQty,@FlexDouble() double totalRevenue
});




}
/// @nodoc
class _$TopProductCopyWithImpl<$Res>
    implements $TopProductCopyWith<$Res> {
  _$TopProductCopyWithImpl(this._self, this._then);

  final TopProduct _self;
  final $Res Function(TopProduct) _then;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? totalQty = null,Object? totalRevenue = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalQty: null == totalQty ? _self.totalQty : totalQty // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TopProduct].
extension TopProductPatterns on TopProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopProduct value)  $default,){
final _that = this;
switch (_that) {
case _TopProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopProduct value)?  $default,){
final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name, @FlexDouble()  double totalQty, @FlexDouble()  double totalRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
return $default(_that.id,_that.name,_that.totalQty,_that.totalRevenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name, @FlexDouble()  double totalQty, @FlexDouble()  double totalRevenue)  $default,) {final _that = this;
switch (_that) {
case _TopProduct():
return $default(_that.id,_that.name,_that.totalQty,_that.totalRevenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name, @FlexDouble()  double totalQty, @FlexDouble()  double totalRevenue)?  $default,) {final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
return $default(_that.id,_that.name,_that.totalQty,_that.totalRevenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopProduct implements TopProduct {
  const _TopProduct({this.id, required this.name, @FlexDouble() this.totalQty = 0, @FlexDouble() this.totalRevenue = 0});
  factory _TopProduct.fromJson(Map<String, dynamic> json) => _$TopProductFromJson(json);

@override final  String? id;
@override final  String name;
@override@JsonKey()@FlexDouble() final  double totalQty;
@override@JsonKey()@FlexDouble() final  double totalRevenue;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopProductCopyWith<_TopProduct> get copyWith => __$TopProductCopyWithImpl<_TopProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.totalQty, totalQty) || other.totalQty == totalQty)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,totalQty,totalRevenue);

@override
String toString() {
  return 'TopProduct(id: $id, name: $name, totalQty: $totalQty, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class _$TopProductCopyWith<$Res> implements $TopProductCopyWith<$Res> {
  factory _$TopProductCopyWith(_TopProduct value, $Res Function(_TopProduct) _then) = __$TopProductCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name,@FlexDouble() double totalQty,@FlexDouble() double totalRevenue
});




}
/// @nodoc
class __$TopProductCopyWithImpl<$Res>
    implements _$TopProductCopyWith<$Res> {
  __$TopProductCopyWithImpl(this._self, this._then);

  final _TopProduct _self;
  final $Res Function(_TopProduct) _then;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? totalQty = null,Object? totalRevenue = null,}) {
  return _then(_TopProduct(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalQty: null == totalQty ? _self.totalQty : totalQty // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PendingPayment {

@FlexInt() int get totalUnpaid;@FlexInt() int get totalDp;@FlexDouble() double get unpaidAmount;@FlexDouble() double get dpRemainingAmount;
/// Create a copy of PendingPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingPaymentCopyWith<PendingPayment> get copyWith => _$PendingPaymentCopyWithImpl<PendingPayment>(this as PendingPayment, _$identity);

  /// Serializes this PendingPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingPayment&&(identical(other.totalUnpaid, totalUnpaid) || other.totalUnpaid == totalUnpaid)&&(identical(other.totalDp, totalDp) || other.totalDp == totalDp)&&(identical(other.unpaidAmount, unpaidAmount) || other.unpaidAmount == unpaidAmount)&&(identical(other.dpRemainingAmount, dpRemainingAmount) || other.dpRemainingAmount == dpRemainingAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUnpaid,totalDp,unpaidAmount,dpRemainingAmount);

@override
String toString() {
  return 'PendingPayment(totalUnpaid: $totalUnpaid, totalDp: $totalDp, unpaidAmount: $unpaidAmount, dpRemainingAmount: $dpRemainingAmount)';
}


}

/// @nodoc
abstract mixin class $PendingPaymentCopyWith<$Res>  {
  factory $PendingPaymentCopyWith(PendingPayment value, $Res Function(PendingPayment) _then) = _$PendingPaymentCopyWithImpl;
@useResult
$Res call({
@FlexInt() int totalUnpaid,@FlexInt() int totalDp,@FlexDouble() double unpaidAmount,@FlexDouble() double dpRemainingAmount
});




}
/// @nodoc
class _$PendingPaymentCopyWithImpl<$Res>
    implements $PendingPaymentCopyWith<$Res> {
  _$PendingPaymentCopyWithImpl(this._self, this._then);

  final PendingPayment _self;
  final $Res Function(PendingPayment) _then;

/// Create a copy of PendingPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUnpaid = null,Object? totalDp = null,Object? unpaidAmount = null,Object? dpRemainingAmount = null,}) {
  return _then(_self.copyWith(
totalUnpaid: null == totalUnpaid ? _self.totalUnpaid : totalUnpaid // ignore: cast_nullable_to_non_nullable
as int,totalDp: null == totalDp ? _self.totalDp : totalDp // ignore: cast_nullable_to_non_nullable
as int,unpaidAmount: null == unpaidAmount ? _self.unpaidAmount : unpaidAmount // ignore: cast_nullable_to_non_nullable
as double,dpRemainingAmount: null == dpRemainingAmount ? _self.dpRemainingAmount : dpRemainingAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingPayment].
extension PendingPaymentPatterns on PendingPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingPayment value)  $default,){
final _that = this;
switch (_that) {
case _PendingPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingPayment value)?  $default,){
final _that = this;
switch (_that) {
case _PendingPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@FlexInt()  int totalUnpaid, @FlexInt()  int totalDp, @FlexDouble()  double unpaidAmount, @FlexDouble()  double dpRemainingAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingPayment() when $default != null:
return $default(_that.totalUnpaid,_that.totalDp,_that.unpaidAmount,_that.dpRemainingAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@FlexInt()  int totalUnpaid, @FlexInt()  int totalDp, @FlexDouble()  double unpaidAmount, @FlexDouble()  double dpRemainingAmount)  $default,) {final _that = this;
switch (_that) {
case _PendingPayment():
return $default(_that.totalUnpaid,_that.totalDp,_that.unpaidAmount,_that.dpRemainingAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@FlexInt()  int totalUnpaid, @FlexInt()  int totalDp, @FlexDouble()  double unpaidAmount, @FlexDouble()  double dpRemainingAmount)?  $default,) {final _that = this;
switch (_that) {
case _PendingPayment() when $default != null:
return $default(_that.totalUnpaid,_that.totalDp,_that.unpaidAmount,_that.dpRemainingAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingPayment implements PendingPayment {
  const _PendingPayment({@FlexInt() this.totalUnpaid = 0, @FlexInt() this.totalDp = 0, @FlexDouble() this.unpaidAmount = 0, @FlexDouble() this.dpRemainingAmount = 0});
  factory _PendingPayment.fromJson(Map<String, dynamic> json) => _$PendingPaymentFromJson(json);

@override@JsonKey()@FlexInt() final  int totalUnpaid;
@override@JsonKey()@FlexInt() final  int totalDp;
@override@JsonKey()@FlexDouble() final  double unpaidAmount;
@override@JsonKey()@FlexDouble() final  double dpRemainingAmount;

/// Create a copy of PendingPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingPaymentCopyWith<_PendingPayment> get copyWith => __$PendingPaymentCopyWithImpl<_PendingPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingPayment&&(identical(other.totalUnpaid, totalUnpaid) || other.totalUnpaid == totalUnpaid)&&(identical(other.totalDp, totalDp) || other.totalDp == totalDp)&&(identical(other.unpaidAmount, unpaidAmount) || other.unpaidAmount == unpaidAmount)&&(identical(other.dpRemainingAmount, dpRemainingAmount) || other.dpRemainingAmount == dpRemainingAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUnpaid,totalDp,unpaidAmount,dpRemainingAmount);

@override
String toString() {
  return 'PendingPayment(totalUnpaid: $totalUnpaid, totalDp: $totalDp, unpaidAmount: $unpaidAmount, dpRemainingAmount: $dpRemainingAmount)';
}


}

/// @nodoc
abstract mixin class _$PendingPaymentCopyWith<$Res> implements $PendingPaymentCopyWith<$Res> {
  factory _$PendingPaymentCopyWith(_PendingPayment value, $Res Function(_PendingPayment) _then) = __$PendingPaymentCopyWithImpl;
@override @useResult
$Res call({
@FlexInt() int totalUnpaid,@FlexInt() int totalDp,@FlexDouble() double unpaidAmount,@FlexDouble() double dpRemainingAmount
});




}
/// @nodoc
class __$PendingPaymentCopyWithImpl<$Res>
    implements _$PendingPaymentCopyWith<$Res> {
  __$PendingPaymentCopyWithImpl(this._self, this._then);

  final _PendingPayment _self;
  final $Res Function(_PendingPayment) _then;

/// Create a copy of PendingPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUnpaid = null,Object? totalDp = null,Object? unpaidAmount = null,Object? dpRemainingAmount = null,}) {
  return _then(_PendingPayment(
totalUnpaid: null == totalUnpaid ? _self.totalUnpaid : totalUnpaid // ignore: cast_nullable_to_non_nullable
as int,totalDp: null == totalDp ? _self.totalDp : totalDp // ignore: cast_nullable_to_non_nullable
as int,unpaidAmount: null == unpaidAmount ? _self.unpaidAmount : unpaidAmount // ignore: cast_nullable_to_non_nullable
as double,dpRemainingAmount: null == dpRemainingAmount ? _self.dpRemainingAmount : dpRemainingAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
