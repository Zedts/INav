/// Model for Islamic calendar data
class CalendarModel {
  final GregorianDate gregorian;
  final HijriDate hijri;

  const CalendarModel({
    required this.gregorian,
    required this.hijri,
  });

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return CalendarModel(
      gregorian: GregorianDate.fromJson(data['ce'] as Map<String, dynamic>),
      hijri: HijriDate.fromJson(data['hijr'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'ce': gregorian.toJson(),
        'hijr': hijri.toJson(),
      },
    };
  }

  @override
  String toString() => 'CalendarModel(gregorian: ${gregorian.date}, hijri: ${hijri.date})';
}

/// Gregorian (Common Era) date
class GregorianDate {
  final String date; // e.g., "2024-01-20"
  final String day; // e.g., "Saturday"

  const GregorianDate({
    required this.date,
    required this.day,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'] as String,
      day: json['day'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
    };
  }
}

/// Hijri (Islamic) date
class HijriDate {
  final String date; // e.g., "12 Rajab 1445 AH"
  final String day; // e.g., "Saturday"
  final int year;
  final int month;
  final int dayOfMonth;
  final String monthName; // e.g., "Rajab"

  const HijriDate({
    required this.date,
    required this.day,
    required this.year,
    required this.month,
    required this.dayOfMonth,
    required this.monthName,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] as String,
      day: json['day'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      month: json['month'] as int? ?? 0,
      dayOfMonth: json['day_of_month'] as int? ?? 0,
      monthName: json['month_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'year': year,
      'month': month,
      'day_of_month': dayOfMonth,
      'month_name': monthName,
    };
  }

  /// Get formatted Hijri date (e.g., "12 Rajab 1445 AH")
  String get formattedDate => '$dayOfMonth $monthName $year AH';
}
