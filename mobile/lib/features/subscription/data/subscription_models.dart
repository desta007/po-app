import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_models.freezed.dart';
part 'subscription_models.g.dart';

/// Response `/api/subscription/status` (raw JSON).
@freezed
abstract class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    @Default('free') String plan,
    @Default('Gratis') String planLabel,
    @Default(false) bool isPremium,
    LatestSubscription? latestSubscription,
  }) = _SubscriptionStatus;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);
}

@freezed
abstract class LatestSubscription with _$LatestSubscription {
  const LatestSubscription._();

  const factory LatestSubscription({
    required String id,
    required String status,
    String? statusLabel,
    String? requestedAt,
    String? startsAt,
    String? expiresAt,
    String? rejectReason,
  }) = _LatestSubscription;

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';

  factory LatestSubscription.fromJson(Map<String, dynamic> json) =>
      _$LatestSubscriptionFromJson(json);
}

/// Satu baris kuota `/api/quota/usage` — `limit` null berarti tak terbatas.
@freezed
abstract class QuotaItem with _$QuotaItem {
  const QuotaItem._();

  const factory QuotaItem({
    @Default(0) int current,
    int? limit,
  }) = _QuotaItem;

  bool get isUnlimited => limit == null;
  double get ratio =>
      isUnlimited || limit == 0 ? 0 : (current / limit!).clamp(0, 1);

  factory QuotaItem.fromJson(Map<String, dynamic> json) =>
      _$QuotaItemFromJson(json);
}

@freezed
abstract class QuotaUsage with _$QuotaUsage {
  const factory QuotaUsage({
    @Default(false) bool isPremium,
    @Default(QuotaItem()) QuotaItem poMonthly,
    @Default(QuotaItem()) QuotaItem products,
    @Default(QuotaItem()) QuotaItem teamMembers,
  }) = _QuotaUsage;

  factory QuotaUsage.fromJson(Map<String, dynamic> json) =>
      _$QuotaUsageFromJson(json);
}
