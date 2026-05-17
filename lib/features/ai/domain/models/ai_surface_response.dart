import '../../../../core/utils/app_id_generator.dart';

enum AiComponentType {
  sectionHeader('section_header'),
  kpiCard('kpi_card'),
  rankingList('ranking_list'),
  actionButton('action_button'),
  emptyState('empty_state'),
  errorState('error_state');

  const AiComponentType(this.wireValue);

  final String wireValue;

  static AiComponentType fromWireValue(String raw) {
    return AiComponentType.values.firstWhere(
      (value) => value.wireValue == raw,
      orElse: () =>
          throw FormatException('Unsupported AI component type: $raw'),
    );
  }
}

enum AiActionType {
  navigate('navigate'),
  prompt('prompt'),
  retry('retry');

  const AiActionType(this.wireValue);

  final String wireValue;

  static AiActionType fromWireValue(String raw) {
    return AiActionType.values.firstWhere(
      (value) => value.wireValue == raw,
      orElse: () => throw FormatException('Unsupported AI action type: $raw'),
    );
  }
}

enum AiTimeRange {
  today('today'),
  last7Days('last_7_days'),
  month('month'),
  quarter('quarter'),
  custom('custom');

  const AiTimeRange(this.wireValue);

  final String wireValue;

  static AiTimeRange fromWireValue(String raw) {
    final normalized = raw.trim().toLowerCase();
    return AiTimeRange.values.firstWhere(
      (value) => value.wireValue == normalized,
      orElse: () => throw FormatException('Unsupported AI time range: $raw'),
    );
  }
}

class AiTimeframe {
  const AiTimeframe({
    required this.range,
    this.year,
    this.month,
    this.quarter,
    this.startDate,
    this.endDate,
  }) : assert(
         month == null || (month >= 1 && month <= 12),
         'Month must be between 1 and 12.',
       ),
       assert(
         quarter == null || (quarter >= 1 && quarter <= 4),
         'Quarter must be between 1 and 4.',
       ),
       assert(
         range != AiTimeRange.month ||
             ((year == null && month == null) ||
                 (year != null && month != null)),
         'Year and month must be provided together.',
       ),
       assert(
         range != AiTimeRange.quarter ||
             ((year == null && quarter == null) ||
                 (year != null && quarter != null)),
         'Year and quarter must be provided together.',
       ),
       assert(
         range != AiTimeRange.custom ||
             ((startDate == null && endDate == null) ||
                 (startDate != null && endDate != null)),
         'Start and end dates must be provided together.',
       );

  final AiTimeRange range;
  final int? year;
  final int? month;
  final int? quarter;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasSpecificMonth =>
      range == AiTimeRange.month && year != null && month != null;

  bool get hasSpecificQuarter =>
      range == AiTimeRange.quarter && year != null && quarter != null;

  bool get hasCustomDateRange =>
      range == AiTimeRange.custom && startDate != null && endDate != null;
}

class AiAction {
  const AiAction({
    required this.id,
    required this.label,
    required this.type,
    this.route,
    this.prompt,
  });

  final String id;
  final String label;
  final AiActionType type;
  final String? route;
  final String? prompt;

  factory AiAction.fromJson(Map<String, dynamic> json) {
    return AiAction(
      id: json['id'] as String? ?? generateId(),
      label: json['label'] as String? ?? '',
      type: AiActionType.fromWireValue(json['type'] as String? ?? ''),
      route: json['route'] as String?,
      prompt: json['prompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.wireValue,
      if (route != null) 'route': route,
      if (prompt != null) 'prompt': prompt,
    };
  }
}

class AiRankingItem {
  const AiRankingItem({
    required this.id,
    required this.label,
    required this.value,
    this.caption,
  });

  final String id;
  final String label;
  final String value;
  final String? caption;

  factory AiRankingItem.fromJson(Map<String, dynamic> json) {
    return AiRankingItem(
      id: json['id'] as String? ?? generateId(),
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      if (caption != null) 'caption': caption,
    };
  }
}

class AiComponent {
  const AiComponent({
    required this.id,
    required this.type,
    this.title,
    this.subtitle,
    this.value,
    this.badge,
    this.action,
    this.items = const [],
  });

  final String id;
  final AiComponentType type;
  final String? title;
  final String? subtitle;
  final String? value;
  final String? badge;
  final AiAction? action;
  final List<AiRankingItem> items;

  factory AiComponent.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return AiComponent(
      id: json['id'] as String? ?? generateId(),
      type: AiComponentType.fromWireValue(json['type'] as String? ?? ''),
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      value: json['value'] as String?,
      badge: json['badge'] as String?,
      action: json['action'] is Map<String, dynamic>
          ? AiAction.fromJson(json['action'] as Map<String, dynamic>)
          : null,
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(AiRankingItem.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.wireValue,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (value != null) 'value': value,
      if (badge != null) 'badge': badge,
      if (items.isNotEmpty)
        'items': items.map((item) => item.toJson()).toList(),
      if (action != null) 'action': action!.toJson(),
    };
  }
}

class AiSurfaceResponse {
  const AiSurfaceResponse({
    required this.surfaceId,
    required this.components,
    this.title,
    this.summary,
  });

  final String surfaceId;
  final String? title;
  final String? summary;
  final List<AiComponent> components;

  factory AiSurfaceResponse.fromJson(Map<String, dynamic> json) {
    final rawComponents = json['components'];
    return AiSurfaceResponse(
      surfaceId: json['surfaceId'] as String? ?? generateId(),
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      components: rawComponents is List
          ? rawComponents
                .whereType<Map<String, dynamic>>()
                .map(AiComponent.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surfaceId': surfaceId,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      'components': components.map((component) => component.toJson()).toList(),
    };
  }
}

class SalonRevenueSummary {
  const SalonRevenueSummary({
    required this.range,
    required this.rangeLabel,
    required this.currencyCode,
    required this.grossSales,
    required this.transactionCount,
    required this.averageTicket,
  });

  final AiTimeRange range;
  final String rangeLabel;
  final String currencyCode;
  final double grossSales;
  final int transactionCount;
  final double averageTicket;

  Map<String, Object?> toToolPayload() {
    return {
      'range': range.wireValue,
      'rangeLabel': rangeLabel,
      'currencyCode': currencyCode,
      'grossSales': grossSales,
      'transactionCount': transactionCount,
      'averageTicket': averageTicket,
    };
  }
}

class TopBarberSnapshot {
  const TopBarberSnapshot({
    required this.employeeId,
    required this.employeeName,
    required this.salesAmount,
    required this.transactionsCount,
    required this.averageTicket,
    required this.rank,
    this.photoUrl,
  });

  final String employeeId;
  final String employeeName;
  final String? photoUrl;
  final double salesAmount;
  final int transactionsCount;
  final double averageTicket;
  final int rank;

  Map<String, Object?> toToolPayload() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'salesAmount': salesAmount,
      'transactionsCount': transactionsCount,
      'averageTicket': averageTicket,
      'rank': rank,
    };
  }
}
