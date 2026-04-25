import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _japaneseAvailable = true;

  bool get japaneseAvailable => _japaneseAvailable;

  Future<void> initialize() async {
    if (_initialized) return;

    // Google TTS 엔진 우선 사용 (없으면 기기 기본 엔진 사용)
    try {
      await _tts.setEngine('com.google.android.tts');
    } catch (_) {}

    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // -1: 미지원, -2: 언어팩 미설치
    final result = await _tts.setLanguage('ja-JP');
    _japaneseAvailable = result != -1 && result != -2;
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await initialize();
    if (!_japaneseAvailable) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
