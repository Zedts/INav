import 'ayah_model.dart';

/// API v3 Model - Represents detailed Surah data with all ayahs
/// Used exclusively for the reading screen detail view
/// Separate from v2 SurahModel to maintain clean API separation
class SurahDetailModel {
  final int number;
  final String name;
  final String nameLatin;
  final int numberOfAyahs;
  final String translation;
  final String revelation;
  final String description;
  final String audioUrl;
  final List<AyahModel> ayahs;

  SurahDetailModel({
    required this.number,
    required this.name,
    required this.nameLatin,
    required this.numberOfAyahs,
    required this.translation,
    required this.revelation,
    required this.description,
    required this.audioUrl,
    required this.ayahs,
  });

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) {
    // Extract data object from API response
    final data = json['data'] as Map<String, dynamic>;

    return SurahDetailModel(
      number: data['number'] as int,
      name: data['name'] as String,
      nameLatin: data['name_latin'] as String,
      numberOfAyahs: data['number_of_ayahs'] as int,
      translation: data['translation'] as String? ?? '',
      revelation: data['revelation'] as String? ?? '',
      description: data['description'] as String? ?? '',
      audioUrl: data['audio_url'] as String? ?? '',
      ayahs: (data['ayahs'] as List<dynamic>?)
              ?.map((ayah) => AyahModel.fromJson(ayah as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'number': number,
        'name': name,
        'name_latin': nameLatin,
        'number_of_ayahs': numberOfAyahs,
        'translation': translation,
        'revelation': revelation,
        'description': description,
        'audio_url': audioUrl,
        'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
      },
    };
  }

  /// Helper to check if this surah is Meccan
  bool get isMeccan => revelation.toLowerCase().contains('mak');

  /// Helper to get revelation in English
  String get revelationEn => isMeccan ? 'Meccan' : 'Medinan';
}
