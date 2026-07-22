/// Model for daily prayer times (Sholat schedule)
class PrayerTimesModel {
  final String cityName;
  final String province;
  final String date;
  final String imsak;
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const PrayerTimesModel({
    required this.cityName,
    required this.province,
    required this.date,
    required this.imsak,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final jadwal = data['jadwal'] as Map<String, dynamic>;

    return PrayerTimesModel(
      cityName:
          (data['lokasi'] as String?) ??
          (data['kabko'] as String?) ??
          'Unknown',
      province:
          (data['daerah'] as String?) ?? (data['prov'] as String?) ?? 'Unknown',
      date: jadwal['tanggal'] as String,
      imsak: jadwal['imsak'] as String,
      fajr: jadwal['subuh'] as String,
      dhuhr: jadwal['dzuhur'] as String,
      asr: jadwal['ashar'] as String,
      maghrib: jadwal['maghrib'] as String,
      isha: jadwal['isya'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'kabko': cityName,
        'prov': province,
        'jadwal': {
          'tanggal': date,
          'imsak': imsak,
          'subuh': fajr,
          'dzuhur': dhuhr,
          'ashar': asr,
          'maghrib': maghrib,
          'isya': isha,
        },
      },
    };
  }

  /// Get all prayer times as a map
  Map<String, String> getAllPrayerTimes() {
    return {
      'Fajr': fajr,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  /// Get prayer time by name
  String? getPrayerTime(String prayerName) {
    final times = getAllPrayerTimes();
    return times[prayerName];
  }

  @override
  String toString() => 'PrayerTimesModel($cityName, $date)';
}
