class SurahModel {
  final String audioUrl;
  final String nameEn;
  final String nameId;
  final String nameLong;
  final String nameShort;
  final int number;
  final int numberOfVerses;
  final int sequence;
  final String revelation;
  final String revelationEn;
  final String revelationId;
  final String tafsir;
  final String translationEn;
  final String translationId;

  SurahModel({
    required this.audioUrl,
    required this.nameEn,
    required this.nameId,
    required this.nameLong,
    required this.nameShort,
    required this.number,
    required this.numberOfVerses,
    required this.sequence,
    required this.revelation,
    required this.revelationEn,
    required this.revelationId,
    required this.tafsir,
    required this.translationEn,
    required this.translationId,
  });

  bool get isMeccan => revelationEn == 'Meccan';

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      audioUrl: json['audio_url'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameId: json['name_id'] as String? ?? '',
      nameLong: json['name_long'] as String? ?? '',
      nameShort: json['name_short'] as String? ?? '',
      number: int.tryParse((json['number']?.toString()) ?? '0') ?? 0,
      numberOfVerses:
          int.tryParse((json['number_of_verses']?.toString()) ?? '0') ?? 0,
      sequence: int.tryParse((json['sequence']?.toString()) ?? '0') ?? 0,
      revelation: json['revelation'] as String? ?? '',
      revelationEn: json['revelation_en'] as String? ?? '',
      revelationId: json['revelation_id'] as String? ?? '',
      tafsir: json['tafsir'] as String? ?? '',
      translationEn: json['translation_en'] as String? ?? '',
      translationId: json['translation_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audio_url': audioUrl,
      'name_en': nameEn,
      'name_id': nameId,
      'name_long': nameLong,
      'name_short': nameShort,
      'number': number.toString(),
      'number_of_verses': numberOfVerses.toString(),
      'sequence': sequence.toString(),
      'revelation': revelation,
      'revelation_en': revelationEn,
      'revelation_id': revelationId,
      'tafsir': tafsir,
      'translation_en': translationEn,
      'translation_id': translationId,
    };
  }
}
