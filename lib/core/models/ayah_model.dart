/// API v3 Model - Represents a single Ayah (verse) from the Quran
/// Used exclusively for the reading screen detail view
class AyahModel {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String arab;
  final String translation;
  final String audioUrl;
  final String imageUrl;
  final AyahTafsir tafsir;
  final AyahMeta meta;

  AyahModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arab,
    required this.translation,
    required this.audioUrl,
    required this.imageUrl,
    required this.tafsir,
    required this.meta,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      id: json['id'] as int,
      surahNumber: json['surah_number'] as int,
      ayahNumber: json['ayah_number'] as int,
      arab: json['arab'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audio_url'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      tafsir: AyahTafsir.fromJson(json['tafsir'] as Map<String, dynamic>),
      meta: AyahMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'arab': arab,
      'translation': translation,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'tafsir': tafsir.toJson(),
      'meta': meta.toJson(),
    };
  }
}

/// Tafsir (interpretation) data for an Ayah
class AyahTafsir {
  final TafsirKemenag kemenag;
  final String quraish;
  final String jalalayn;

  AyahTafsir({
    required this.kemenag,
    required this.quraish,
    required this.jalalayn,
  });

  factory AyahTafsir.fromJson(Map<String, dynamic> json) {
    return AyahTafsir(
      kemenag: TafsirKemenag.fromJson(
        json['kemenag'] as Map<String, dynamic>,
      ),
      quraish: json['quraish'] as String? ?? '',
      jalalayn: json['jalalayn'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kemenag': kemenag.toJson(),
      'quraish': quraish,
      'jalalayn': jalalayn,
    };
  }
}

/// Kemenag tafsir with short and long versions
class TafsirKemenag {
  final String short;
  final String long;

  TafsirKemenag({
    required this.short,
    required this.long,
  });

  factory TafsirKemenag.fromJson(Map<String, dynamic> json) {
    return TafsirKemenag(
      short: json['short'] as String? ?? '',
      long: json['long'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'short': short,
      'long': long,
    };
  }
}

/// Metadata for an Ayah (juz, page, etc.)
class AyahMeta {
  final int juz;
  final int page;
  final int manzil;
  final int ruku;
  final int hizbQuarter;
  final AyahSajda sajda;

  AyahMeta({
    required this.juz,
    required this.page,
    required this.manzil,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory AyahMeta.fromJson(Map<String, dynamic> json) {
    return AyahMeta(
      juz: json['juz'] as int,
      page: json['page'] as int,
      manzil: json['manzil'] as int,
      ruku: json['ruku'] as int,
      hizbQuarter: json['hizb_quarter'] as int,
      sajda: AyahSajda.fromJson(json['sajda'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juz': juz,
      'page': page,
      'manzil': manzil,
      'ruku': ruku,
      'hizb_quarter': hizbQuarter,
      'sajda': sajda.toJson(),
    };
  }
}

/// Sajda (prostration) information for an Ayah
class AyahSajda {
  final bool recommended;
  final bool obligatory;

  AyahSajda({
    required this.recommended,
    required this.obligatory,
  });

  factory AyahSajda.fromJson(Map<String, dynamic> json) {
    return AyahSajda(
      recommended: json['recommended'] as bool? ?? false,
      obligatory: json['obligatory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended': recommended,
      'obligatory': obligatory,
    };
  }
}
