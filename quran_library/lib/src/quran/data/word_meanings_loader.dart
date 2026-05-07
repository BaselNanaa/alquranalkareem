part of '/quran.dart';

/// نموذج مدخل واحد لمعنى كلمة (أو نطاق كلمات).
class WordMeaningEntry {
  final int surah;
  final int ayah;
  final int startWord;
  final int endWord;
  final String text;
  final String color;

  const WordMeaningEntry({
    required this.surah,
    required this.ayah,
    required this.startWord,
    required this.endWord,
    required this.text,
    required this.color,
  });

  factory WordMeaningEntry.fromJson(Map<String, dynamic> json) {
    return WordMeaningEntry(
      surah: (json['surah'] as num?)?.toInt() ?? 0,
      ayah: (json['ayah'] as num).toInt(),
      startWord: (json['start_word'] as num).toInt(),
      endWord: (json['end_word'] as num).toInt(),
      text: (json['text'] ?? '').toString(),
      color: (json['color'] ?? '#000000').toString(),
    );
  }
}

/// نموذج صفحة معاني كلمات كاملة.
class WordMeaningsPage {
  final int pageNumber;
  final List<WordMeaningEntry> meanings;

  const WordMeaningsPage({
    required this.pageNumber,
    required this.meanings,
  });

  factory WordMeaningsPage.fromJson(int pageNumber, Map<String, dynamic> json) {
    final list = (json['word_meanings'] as List<dynamic>? ?? [])
        .map((e) => WordMeaningEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return WordMeaningsPage(
      pageNumber: pageNumber,
      meanings: list,
    );
  }

  /// البحث عن معنى ينطبق على سورة وآية ورقم كلمة محددين.
  WordMeaningEntry? findMeaning(int surahNumber, int ayahNumber, int wordNumber) {
    for (final m in meanings) {
      if ((m.surah == 0 || m.surah == surahNumber) &&
          m.ayah == ayahNumber &&
          wordNumber >= m.startWord &&
          wordNumber <= m.endWord) {
        return m;
      }
    }
    return null;
  }
}

/// محمّل ملفات JSON لمعاني الكلمات مع ذاكرة تخزين مؤقت داخلية.
class WordMeaningsLoader {
  static final Map<int, WordMeaningsPage> _cache = {};

  /// يحمل ملف معاني الصفحة إن وجد، أو يرجع `null`.
  static Future<WordMeaningsPage?> load(int pageNumber) async {
    if (_cache.containsKey(pageNumber)) {
      return _cache[pageNumber];
    }
    try {
      final assetPath = 'assets/json/word_meanings/word_meanings_$pageNumber.json';
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final page = WordMeaningsPage.fromJson(pageNumber, json);
      _cache[pageNumber] = page;
      return page;
    } catch (_) {
      // الملف غير موجود أو تالف — نتجاهل الصمت
      return null;
    }
  }

  static void clearCache() => _cache.clear();
}
