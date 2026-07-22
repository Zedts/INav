import '../models/calendar_model.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';

/// Service for fetching Islamic calendar data
/// Note: MyQuran API v2 does not have calendar endpoints, using local Hijri calculation
class CalendarService {
  final ApiService _apiService;

  CalendarService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Fetch today's calendar (Gregorian + Hijri dates)
  ///
  /// [adjustment] - Optional adjustment in days (default: 0)
  /// [timezone] - Optional timezone (defaults to Asia/Jakarta)
  ///
  /// Returns [CalendarModel] with both Gregorian and Hijri dates
  /// Throws [ApiException] on error
  Future<CalendarModel> getTodayCalendar({
    int adjustment = 0,
    String? timezone,
  }) async {
    try {
      final now = DateTime.now().add(Duration(days: adjustment));
      return _convertToHijri(now);
    } catch (e) {
      throw ApiException('Failed to fetch calendar: ${e.toString()}');
    }
  }

  /// Fetch calendar for a specific Gregorian date
  ///
  /// [year] - Year (e.g., 2024)
  /// [month] - Month (1-12)
  /// [day] - Day of month (1-31)
  /// [adjustment] - Optional adjustment in days
  /// [timezone] - Optional timezone
  ///
  /// Returns [CalendarModel] for the specified date
  Future<CalendarModel> getCalendarByDate(
    int year,
    int month,
    int day, {
    int adjustment = 0,
    String? timezone,
  }) async {
    try {
      final date = DateTime(year, month, day).add(Duration(days: adjustment));
      return _convertToHijri(date);
    } catch (e) {
      throw ApiException('Failed to fetch calendar for date: ${e.toString()}');
    }
  }

  /// Convert Gregorian date to Hijri using Umm al-Qura algorithm approximation
  CalendarModel _convertToHijri(DateTime gregorian) {
    // Umm al-Qura approximation algorithm
    // Based on the tabular Islamic calendar with epoch adjustment

    final int y = gregorian.year;
    final int m = gregorian.month;
    final int d = gregorian.day;

    // Calculate Julian Day Number
    int a = (14 - m) ~/ 12;
    int y2 = y + 4800 - a;
    int m2 = m + 12 * a - 3;

    int jdn =
        d +
        (153 * m2 + 2) ~/ 5 +
        365 * y2 +
        y2 ~/ 4 -
        y2 ~/ 100 +
        y2 ~/ 400 -
        32045;

    // Convert Julian Day to Islamic date
    // Islamic epoch is JD 1948440 (July 16, 622 CE)
    int l = jdn - 1948440 + 10632;
    int n = ((l - 1) * 30 + 10646) ~/ 10631;
    l = l - ((n - 1) * 10631) ~/ 30 + 1;
    int j = ((l - 1) * 11) ~/ 325;

    int hijriDay = l - (j * 325) ~/ 11;
    int hijriMonth = j + 1;
    int hijriYear = n;

    // Adjust for standard Hijri calendar
    if (hijriDay > 29) {
      if (hijriMonth == 12) {
        hijriDay = 29;
      } else if ([2, 4, 6, 8, 10].contains(hijriMonth)) {
        hijriDay = 29;
      }
    }

    final hijriMonthNames = [
      'Muharram',
      'Safar',
      'Rabi\' al-Awwal',
      'Rabi\' al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi\'dah',
      'Dhu al-Hijjah',
    ];

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[gregorian.weekday - 1];

    final gregorianDate = GregorianDate(
      date: DateFormat('yyyy-MM-dd').format(gregorian),
      day: dayName,
    );

    final hijriDate = HijriDate(
      date: '$hijriDay ${hijriMonthNames[hijriMonth - 1]} $hijriYear AH',
      day: dayName,
      year: hijriYear,
      month: hijriMonth,
      dayOfMonth: hijriDay,
      monthName: hijriMonthNames[hijriMonth - 1],
    );

    return CalendarModel(gregorian: gregorianDate, hijri: hijriDate);
  }

  /// Dispose service
  void dispose() {
    _apiService.dispose();
  }
}
