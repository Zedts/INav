/// Model for verse data from MyQuran API
class VerseModel {
  final String arabic;
  final String translation;
  final String surahName;
  final String ayahNumber;
  final String surahNumber;

  VerseModel({
    required this.arabic,
    required this.translation,
    required this.surahName,
    required this.ayahNumber,
    required this.surahNumber,
  });

  /// Create VerseModel from MyQuran API JSON response
  factory VerseModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;
      final info = data['info'] as Map<String, dynamic>;
      final surat = info['surat'] as Map<String, dynamic>;
      final nama = surat['nama'] as Map<String, dynamic>;
      final ayat = data['ayat'] as Map<String, dynamic>;

      return VerseModel(
        arabic: ayat['arab'] as String? ?? '',
        translation: ayat['text'] as String? ?? '',
        surahName: nama['id'] as String? ?? '',
        ayahNumber: ayat['ayah'] as String? ?? '',
        surahNumber: ayat['surah'] as String? ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse verse data: $e');
    }
  }

  /// Convert VerseModel to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'translation': translation,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'surahNumber': surahNumber,
    };
  }

  /// Create VerseModel from cached JSON (simplified structure)
  factory VerseModel.fromCachedJson(Map<String, dynamic> json) {
    return VerseModel(
      arabic: json['arabic'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      surahName: json['surahName'] as String? ?? '',
      ayahNumber: json['ayahNumber'] as String? ?? '',
      surahNumber: json['surahNumber'] as String? ?? '',
    );
  }

  /// Get formatted reference (e.g., "Fussilat 41:37")
  String get formattedReference => '$surahName $surahNumber:$ayahNumber';
}
