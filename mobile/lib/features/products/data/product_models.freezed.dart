// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get name; String? get sku; String? get description; String get unit;@FlexDouble() double get price;@FlexDoubleNullable() double? get cost; String? get category; String? get imageUrl; List<String> get images;@FlexDouble() double get stockQty; bool get isActive; bool get showInCatalog; String? get createdAt; String? get updatedAt;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.price, price) || other.price == price)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.showInCatalog, showInCatalog) || other.showInCatalog == showInCatalog)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sku,description,unit,price,cost,category,imageUrl,const DeepCollectionEquality().hash(images),stockQty,isActive,showInCatalog,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, name: $name, sku: $sku, description: $description, unit: $unit, price: $price, cost: $cost, category: $category, imageUrl: $imageUrl, images: $images, stockQty: $stockQty, isActive: $isActive, showInCatalog: $showInCatalog, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? sku, String? description, String unit,@FlexDouble() double price,@FlexDoubleNullable() double? cost, String? category, String? imageUrl, List<String> images,@FlexDouble() double stockQty, bool isActive, bool showInCatalog, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sku = freezed,Object? description = freezed,Object? unit = null,Object? price = null,Object? cost = freezed,Object? category = freezed,Object? imageUrl = freezed,Object? images = null,Object? stockQty = null,Object? isActive = null,Object? showInCatalog = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,stockQty: null == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,showInCatalog: null == showInCatalog ? _self.showInCatalog : showInCatalog // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? sku,  String? description,  String unit, @FlexDouble()  double price, @FlexDoubleNullable()  double? cost,  String? category,  String? imageUrl,  List<String> images, @FlexDouble()  double stockQty,  bool isActive,  bool showInCatalog,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.imageUrl,_that.images,_that.stockQty,_that.isActive,_that.showInCatalog,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? sku,  String? description,  String unit, @FlexDouble()  double price, @FlexDoubleNullable()  double? cost,  String? category,  String? imageUrl,  List<String> images, @FlexDouble()  double stockQty,  bool isActive,  bool showInCatalog,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.imageUrl,_that.images,_that.stockQty,_that.isActive,_that.showInCatalog,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? sku,  String? description,  String unit, @FlexDouble()  double price, @FlexDoubleNullable()  double? cost,  String? category,  String? imageUrl,  List<String> images, @FlexDouble()  double stockQty,  bool isActive,  bool showInCatalog,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.imageUrl,_that.images,_that.stockQty,_that.isActive,_that.showInCatalog,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, this.sku, this.description, this.unit = 'pcs', @FlexDouble() this.price = 0, @FlexDoubleNullable() this.cost, this.category, this.imageUrl, final  List<String> images = const [], @FlexDouble() this.stockQty = 0, this.isActive = true, this.showInCatalog = false, this.createdAt, this.updatedAt}): _images = images;
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? sku;
@override final  String? description;
@override@JsonKey() final  String unit;
@override@JsonKey()@FlexDouble() final  double price;
@override@FlexDoubleNullable() final  double? cost;
@override final  String? category;
@override final  String? imageUrl;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey()@FlexDouble() final  double stockQty;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool showInCatalog;
@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.price, price) || other.price == price)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.showInCatalog, showInCatalog) || other.showInCatalog == showInCatalog)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sku,description,unit,price,cost,category,imageUrl,const DeepCollectionEquality().hash(_images),stockQty,isActive,showInCatalog,createdAt,updatedAt);

@override
String toString() {
  return 'Product(id: $id, name: $name, sku: $sku, description: $description, unit: $unit, price: $price, cost: $cost, category: $category, imageUrl: $imageUrl, images: $images, stockQty: $stockQty, isActive: $isActive, showInCatalog: $showInCatalog, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? sku, String? description, String unit,@FlexDouble() double price,@FlexDoubleNullable() double? cost, String? category, String? imageUrl, List<String> images,@FlexDouble() double stockQty, bool isActive, bool showInCatalog, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sku = freezed,Object? description = freezed,Object? unit = null,Object? price = null,Object? cost = freezed,Object? category = freezed,Object? imageUrl = freezed,Object? images = null,Object? stockQty = null,Object? isActive = null,Object? showInCatalog = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,stockQty: null == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,showInCatalog: null == showInCatalog ? _self.showInCatalog : showInCatalog // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductInput {

 String get name; String? get sku; String? get description; String get unit; double get price; double? get cost; String? get category; double? get stockQty; bool? get isActive; bool? get showInCatalog;
/// Create a copy of ProductInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductInputCopyWith<ProductInput> get copyWith => _$ProductInputCopyWithImpl<ProductInput>(this as ProductInput, _$identity);

  /// Serializes this ProductInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductInput&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.price, price) || other.price == price)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.showInCatalog, showInCatalog) || other.showInCatalog == showInCatalog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sku,description,unit,price,cost,category,stockQty,isActive,showInCatalog);

@override
String toString() {
  return 'ProductInput(name: $name, sku: $sku, description: $description, unit: $unit, price: $price, cost: $cost, category: $category, stockQty: $stockQty, isActive: $isActive, showInCatalog: $showInCatalog)';
}


}

/// @nodoc
abstract mixin class $ProductInputCopyWith<$Res>  {
  factory $ProductInputCopyWith(ProductInput value, $Res Function(ProductInput) _then) = _$ProductInputCopyWithImpl;
@useResult
$Res call({
 String name, String? sku, String? description, String unit, double price, double? cost, String? category, double? stockQty, bool? isActive, bool? showInCatalog
});




}
/// @nodoc
class _$ProductInputCopyWithImpl<$Res>
    implements $ProductInputCopyWith<$Res> {
  _$ProductInputCopyWithImpl(this._self, this._then);

  final ProductInput _self;
  final $Res Function(ProductInput) _then;

/// Create a copy of ProductInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? sku = freezed,Object? description = freezed,Object? unit = null,Object? price = null,Object? cost = freezed,Object? category = freezed,Object? stockQty = freezed,Object? isActive = freezed,Object? showInCatalog = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,stockQty: freezed == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,showInCatalog: freezed == showInCatalog ? _self.showInCatalog : showInCatalog // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductInput].
extension ProductInputPatterns on ProductInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductInput value)  $default,){
final _that = this;
switch (_that) {
case _ProductInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductInput value)?  $default,){
final _that = this;
switch (_that) {
case _ProductInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? sku,  String? description,  String unit,  double price,  double? cost,  String? category,  double? stockQty,  bool? isActive,  bool? showInCatalog)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductInput() when $default != null:
return $default(_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.stockQty,_that.isActive,_that.showInCatalog);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? sku,  String? description,  String unit,  double price,  double? cost,  String? category,  double? stockQty,  bool? isActive,  bool? showInCatalog)  $default,) {final _that = this;
switch (_that) {
case _ProductInput():
return $default(_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.stockQty,_that.isActive,_that.showInCatalog);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? sku,  String? description,  String unit,  double price,  double? cost,  String? category,  double? stockQty,  bool? isActive,  bool? showInCatalog)?  $default,) {final _that = this;
switch (_that) {
case _ProductInput() when $default != null:
return $default(_that.name,_that.sku,_that.description,_that.unit,_that.price,_that.cost,_that.category,_that.stockQty,_that.isActive,_that.showInCatalog);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductInput implements ProductInput {
  const _ProductInput({required this.name, this.sku, this.description, required this.unit, required this.price, this.cost, this.category, this.stockQty, this.isActive, this.showInCatalog});
  factory _ProductInput.fromJson(Map<String, dynamic> json) => _$ProductInputFromJson(json);

@override final  String name;
@override final  String? sku;
@override final  String? description;
@override final  String unit;
@override final  double price;
@override final  double? cost;
@override final  String? category;
@override final  double? stockQty;
@override final  bool? isActive;
@override final  bool? showInCatalog;

/// Create a copy of ProductInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductInputCopyWith<_ProductInput> get copyWith => __$ProductInputCopyWithImpl<_ProductInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductInput&&(identical(other.name, name) || other.name == name)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.description, description) || other.description == description)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.price, price) || other.price == price)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.category, category) || other.category == category)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.showInCatalog, showInCatalog) || other.showInCatalog == showInCatalog));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sku,description,unit,price,cost,category,stockQty,isActive,showInCatalog);

@override
String toString() {
  return 'ProductInput(name: $name, sku: $sku, description: $description, unit: $unit, price: $price, cost: $cost, category: $category, stockQty: $stockQty, isActive: $isActive, showInCatalog: $showInCatalog)';
}


}

/// @nodoc
abstract mixin class _$ProductInputCopyWith<$Res> implements $ProductInputCopyWith<$Res> {
  factory _$ProductInputCopyWith(_ProductInput value, $Res Function(_ProductInput) _then) = __$ProductInputCopyWithImpl;
@override @useResult
$Res call({
 String name, String? sku, String? description, String unit, double price, double? cost, String? category, double? stockQty, bool? isActive, bool? showInCatalog
});




}
/// @nodoc
class __$ProductInputCopyWithImpl<$Res>
    implements _$ProductInputCopyWith<$Res> {
  __$ProductInputCopyWithImpl(this._self, this._then);

  final _ProductInput _self;
  final $Res Function(_ProductInput) _then;

/// Create a copy of ProductInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? sku = freezed,Object? description = freezed,Object? unit = null,Object? price = null,Object? cost = freezed,Object? category = freezed,Object? stockQty = freezed,Object? isActive = freezed,Object? showInCatalog = freezed,}) {
  return _then(_ProductInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,cost: freezed == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,stockQty: freezed == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,showInCatalog: freezed == showInCatalog ? _self.showInCatalog : showInCatalog // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
