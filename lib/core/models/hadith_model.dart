/// Model for hadith data from MyQuran API (`/hadits/perawi/acak`)
class HadithModel {
  final String arabic;
  final String translation;
  final String narrator;
  final String number;

  HadithModel({
    required this.arabic,
    required this.translation,
    required this.narrator,
    required this.number,
  });

  /// Create HadithModel from MyQuran API JSON response
  /// Shape: { info: { perawi: { name } }, data: { number, arab, id } }
  factory HadithModel.fromJson(Map<String, dynamic> json) {
    try {
      final info = json['info'] as Map<String, dynamic>?;
      final perawi = info?['perawi'] as Map<String, dynamic>?;
      final data = json['data'] as Map<String, dynamic>;

      return HadithModel(
        arabic: data['arab'] as String? ?? '',
        translation: data['id'] as String? ?? '',
        narrator: perawi?['name'] as String? ?? '',
        number: data['number']?.toString() ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse hadith data: $e');
    }
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'translation': translation,
      'narrator': narrator,
      'number': number,
    };
  }

  /// Create HadithModel from cached JSON (simplified structure)
  factory HadithModel.fromCachedJson(Map<String, dynamic> json) {
    return HadithModel(
      arabic: json['arabic'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      number: json['number'] as String? ?? '',
    );
  }

  /// Get formatted reference (e.g., "HR. Nasai No. 927")
  String get formattedReference {
    final ref = StringBuffer('HR.');
    if (narrator.isNotEmpty) ref.write(' $narrator');
    if (number.isNotEmpty) ref.write(' No. $number');
    return ref.toString();
  }
}
