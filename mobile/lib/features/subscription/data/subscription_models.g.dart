// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) =>
    _SubscriptionStatus(
      plan: json['plan'] as String? ?? 'free',
      planLabel: json['plan_label'] as String? ?? 'Gratis',
      isPremium: json['is_premium'] as bool? ?? false,
      latestSubscription: json['latest_subscription'] == null
          ? null
          : LatestSubscription.fromJson(
              json['latest_subscription'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SubscriptionStatusToJson(_SubscriptionStatus instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'plan_label': instance.planLabel,
      'is_premium': instance.isPremium,
      'latest_subscription': instance.latestSubscription?.toJson(),
    };

_LatestSubscription _$LatestSubscriptionFromJson(Map<String, dynamic> json) =>
    _LatestSubscription(
      id: json['id'] as String,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String?,
      requestedAt: json['requested_at'] as String?,
      startsAt: json['starts_at'] as String?,
      expiresAt: json['expires_at'] as String?,
      rejectReason: json['reject_reason'] as String?,
    );

Map<String, dynamic> _$LatestSubscriptionToJson(_LatestSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'requested_at': instance.requestedAt,
      'starts_at': instance.startsAt,
      'expires_at': instance.expiresAt,
      'reject_reason': instance.rejectReason,
    };

_QuotaItem _$QuotaItemFromJson(Map<String, dynamic> json) => _QuotaItem(
  current: (json['current'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt(),
);

Map<String, dynamic> _$QuotaItemToJson(_QuotaItem instance) =>
    <String, dynamic>{'current': instance.current, 'limit': instance.limit};

_QuotaUsage _$QuotaUsageFromJson(Map<String, dynamic> json) => _QuotaUsage(
  isPremium: json['is_premium'] as bool? ?? false,
  poMonthly: json['po_monthly'] == null
      ? const QuotaItem()
      : QuotaItem.fromJson(json['po_monthly'] as Map<String, dynamic>),
  products: json['products'] == null
      ? const QuotaItem()
      : QuotaItem.fromJson(json['products'] as Map<String, dynamic>),
  teamMembers: json['team_members'] == null
      ? const QuotaItem()
      : QuotaItem.fromJson(json['team_members'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuotaUsageToJson(_QuotaUsage instance) =>
    <String, dynamic>{
      'is_premium': instance.isPremium,
      'po_monthly': instance.poMonthly.toJson(),
      'products': instance.products.toJson(),
      'team_members': instance.teamMembers.toJson(),
    };
