// ============================================================
// 한자 학습 화면 - Firestore에서 레벨별 한자를 불러와 플래시카드로 표시
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/features/learning/data/repositories/learning_progress_repository.dart';
import 'package:nihongo/features/learning/data/repositories/study_stats_repository.dart';
import 'package:nihongo/features/learning/data/repositories/user_repository.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';
import 'package:nihongo/features/stats/presentation/providers/stats_providers.dart';
import 'package:nihongo/widgets/kanji_card.dart';

class KanjiStudyScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const KanjiStudyScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  ConsumerState<KanjiStudyScreen> createState() => _KanjiStudyScreenState();
}

class _KanjiStudyScreenState extends ConsumerState<KanjiStudyScreen> {
  int _currentIndex = 0;
  bool _isCardFlipped = false;
  int _knownCount = 0;
  int _unknownCount = 0;
  int _learnedCount = 0;

  final Map<String, String> _wordAnswers = {};
  final Map<String, String> _initialWordAnswers = {};
  final Map<String, WordModel> _answeredWords = {};

  DateTime? _studyStartTime;
  String? _uid;
  UserRepository? _userRepository;
  StudyStatsRepository? _studyStatsRepository;
  LearningProgressRepository? _learningProgressRepository;
  FirebaseFirestore? _firestore;

  bool _isSavingStudySession = false;
  bool _hasSavedStudySession = false;

  @override
  void initState() {
    super.initState();
    _studyStartTime = DateTime.now();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _userRepository = ref.read(userRepositoryProvider);
    _studyStatsRepository = ref.read(studyStatsRepositoryProvider);
    _learningProgressRepository = ref.read(learningProgressRepositoryProvider);
    _firestore = FirebaseFirestore.instance;

    _loadInitialProgress();

    if (_uid != null) {
      _userRepository!.updateStreakIfNeeded(_uid!);
    }
  }

  Future<void> _resetProgress() async {
    if (_uid == null) return;

    await _learningProgressRepository!.resetProgress(
      uid: _uid!,
      subCategory: widget.categoryId,
    );

    setState(() {
      _knownCount = 0;
      _unknownCount = 0;
      _learnedCount = 0;
      _currentIndex = 0;
      _isCardFlipped = false;
      _wordAnswers.clear();
      _initialWordAnswers.clear();
      _answeredWords.clear();
    });
  }

  Future<void> _applyAnswer({
    required WordModel word,
    required String newStatus,
  }) async {
    final prev = _wordAnswers[word.id];
    if (prev == newStatus) return;

    setState(() {
      if (prev == 'know') _knownCount--;
      if (prev == 'dontKnow') _unknownCount--;

      if (newStatus == 'know') _knownCount++;
      if (newStatus == 'dontKnow') _unknownCount++;

      if (prev == null) _learnedCount++;

      _wordAnswers[word.id] = newStatus;
      _answeredWords[word.id] = word;
    });
  }

  Future<void> _loadInitialProgress() async {
    if (_uid == null) return;

    final results = await Future.wait([
      _learningProgressRepository!.getProgressCount(
        uid: _uid!,
        subCategory: widget.categoryId,
      ),
      _studyStatsRepository!.getDailyLearnedCount(_uid!),
    ]);

    final progress = results[0]
        as ({int knownCount, int unknownCount, Map<String, String> wordAnswers});
    final learnedCount = results[1] as int;

    if (!mounted) return;

    setState(() {
      _knownCount = progress.knownCount;
      _unknownCount = progress.unknownCount;
      _learnedCount = learnedCount;
      _wordAnswers.addAll(progress.wordAnswers);
      _initialWordAnswers.addAll(progress.wordAnswers);
    });
  }

  Future<void> _saveStudySessionIfNeeded() async {
    if (_isSavingStudySession || _hasSavedStudySession) return;
    if (_uid == null || _studyStartTime == null) return;

    _isSavingStudySession = true;

    try {
      final uid = _uid!;
      final seconds = DateTime.now().difference(_studyStartTime!).inSeconds;

      final changedEntries = <MapEntry<String, String>>[];
      for (final entry in _wordAnswers.entries) {
        final initial = _initialWordAnswers[entry.key];
        if (initial != entry.value) {
          changedEntries.add(entry);
        }
      }

      final newlyAnsweredCount = _wordAnswers.entries
          .where((entry) => _initialWordAnswers[entry.key] == null)
          .length;

      if (seconds > 0) {
        await Future.wait([
          _userRepository!.addStudySeconds(uid, seconds),
          _studyStatsRepository!.addDailyStudySeconds(uid, seconds),
        ]);
      }

      if (newlyAnsweredCount > 0) {
        await Future.wait([
          _userRepository!.addStudyCount(uid, newlyAnsweredCount),
          _studyStatsRepository!.addDailyLearnedCount(uid, newlyAnsweredCount),
        ]);
      }

      if (changedEntries.isNotEmpty) {
        await _saveLearningProgressBatch(
          uid: uid,
          changedEntries: changedEntries,
        );

        await _saveWeakStatsBatch(
          uid: uid,
          changedEntries: changedEntries,
        );
      }

      _updateStatsProviderLocal(
        addedStudySeconds: seconds > 0 ? seconds : 0,
        addedStudyCount: newlyAnsweredCount,
        addedDailyLearnedCount: newlyAnsweredCount,
      );

      _hasSavedStudySession = true;
      ref.read(statsProvider.notifier).refreshStatsSilently();
    } catch (e) {
      print('[한자학습세션] Firestore 에러: $e');
    } finally {
      _isSavingStudySession = false;
    }
  }

  Future<void> _saveLearningProgressBatch({
    required String uid,
    required List<MapEntry<String, String>> changedEntries,
  }) async {
    final batch = _firestore!.batch();

    for (final entry in changedEntries) {
      final word = _answeredWords[entry.key];
      if (word == null) continue;

      final docRef = _firestore!
          .collection('users')
          .doc(uid)
          .collection('learning_progress')
          .doc(word.id);

      batch.set(
        docRef,
        {
          'category': word.category,
          'subCategory': word.subCategory,
          'contentType': word.contentType,
          'content': word.content,
          'meaning': word.meaning.isNotEmpty ? word.meaning.first : '',
          'status': entry.value,
          'lastStudiedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> _saveWeakStatsBatch({
    required String uid,
    required List<MapEntry<String, String>> changedEntries,
  }) async {
    final userRef = _firestore!.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};
    final weakStats = (data['weakStats'] as Map<String, dynamic>?) ?? {};

    final Map<String, _WeakStatCounter> counters = {
      '단어': _WeakStatCounter.fromMap(weakStats['단어']),
      '한자': _WeakStatCounter.fromMap(weakStats['한자']),
      '예문': _WeakStatCounter.fromMap(weakStats['예문']),
      '가타카나': _WeakStatCounter.fromMap(weakStats['가타카나']),
      '히라가나': _WeakStatCounter.fromMap(weakStats['히라가나']),
      '스피킹': _WeakStatCounter.fromMap(weakStats['스피킹']),
    };

    for (final entry in changedEntries) {
      final word = _answeredWords[entry.key];
      if (word == null) continue;

      final initialStatus = _initialWordAnswers[entry.key];
      final finalStatus = entry.value;
      final counter = counters['한자']!;

      if (initialStatus == 'know') {
        counter.know = (counter.know - 1).clamp(0, 1 << 30);
      } else if (initialStatus == 'dontKnow') {
        counter.dontKnow = (counter.dontKnow - 1).clamp(0, 1 << 30);
      }

      if (finalStatus == 'know') {
        counter.know += 1;
      } else if (finalStatus == 'dontKnow') {
        counter.dontKnow += 1;
      }
    }

    await userRef.set({
      'weakStats': {
        for (final entry in counters.entries)
          entry.key: {
            'know': entry.value.know,
            'dontKnow': entry.value.dontKnow,
            'score': _calculateScore(
              know: entry.value.know,
              dontKnow: entry.value.dontKnow,
            ),
          },
      },
    }, SetOptions(merge: true));
  }

  void _updateStatsProviderLocal({
    required int addedStudySeconds,
    required int addedStudyCount,
    required int addedDailyLearnedCount,
  }) {
    final currentStats = ref.read(statsProvider).valueOrNull;
    if (currentStats == null) return;

    final addedMinutes = (addedStudySeconds / 60).round();

    final updatedDailyChart = [...currentStats.dailyChart];
    if (updatedDailyChart.isNotEmpty) {
      final last = updatedDailyChart.last;
      updatedDailyChart[updatedDailyChart.length - 1] = StatsChartItem(
        label: last.label,
        value: last.value + addedMinutes,
      );
    }

    final updatedWeeklyChart = [...currentStats.weeklyChart];
    if (updatedWeeklyChart.isNotEmpty) {
      final last = updatedWeeklyChart.last;
      updatedWeeklyChart[updatedWeeklyChart.length - 1] = StatsChartItem(
        label: last.label,
        value: last.value + addedMinutes,
      );
    }

    final updatedMonthlyChart = [...currentStats.monthlyChart];
    if (updatedMonthlyChart.isNotEmpty) {
      final last = updatedMonthlyChart.last;
      updatedMonthlyChart[updatedMonthlyChart.length - 1] = StatsChartItem(
        label: last.label,
        value: last.value + addedMinutes,
      );
    }

    final updatedWeakAreas = currentStats.weakAreas.map((area) {
      if (area.label == '한자') {
        final total = (_knownCount + _unknownCount);
        final score = total == 0 ? 30 : ((_knownCount / total) * 100).round();
        return StatsWeakAreaItem(label: area.label, weaknessPercent: score);
      }
      return area;
    }).toList();

    final updatedStats = StatsModel(
      totalStudySeconds: currentStats.totalStudySeconds + addedStudySeconds,
      totalStudyCount: currentStats.totalStudyCount + addedStudyCount,
      learnedCount: currentStats.learnedCount + addedDailyLearnedCount,
      streakDays: currentStats.streakDays,
      dailyChart: updatedDailyChart,
      weeklyChart: updatedWeeklyChart,
      monthlyChart: updatedMonthlyChart,
      weakAreas: updatedWeakAreas,
      weakAreaMessage: currentStats.weakAreaMessage,
    );

    ref.read(statsProvider.notifier).updateLocal(updatedStats);
  }

  int _calculateScore({required int know, required int dontKnow}) {
    final total = know + dontKnow;
    if (total == 0) return 30;
    return ((know / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final asyncKanji = ref.watch(kanjiListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: asyncKanji.when(
          loading: () => Column(
            children: [
              _TopBar(
                title: widget.categoryTitle,
                onReset: _resetProgress,
                onBack: _saveStudySessionIfNeeded,
              ),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _TopBar(
                title: widget.categoryTitle,
                onReset: _resetProgress,
                onBack: _saveStudySessionIfNeeded,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '한자를 불러오지 못했어요\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          data: (kanjis) {
            if (kanjis.isEmpty) {
              return Column(
                children: [
                  _TopBar(
                    title: widget.categoryTitle,
                    onReset: _resetProgress,
                    onBack: _saveStudySessionIfNeeded,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '한자가 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            final safeIndex = _currentIndex.clamp(0, kanjis.length - 1);
            final kanji = kanjis[safeIndex];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    title: widget.categoryTitle,
                    onReset: _resetProgress,
                    onBack: _saveStudySessionIfNeeded,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: _StatsBadgeRow(
                      learnedCount: _learnedCount,
                      knownCount: _knownCount,
                      unknownCount: _unknownCount,
                      unseenCount: (kanjis.length - _knownCount - _unknownCount)
                          .clamp(0, kanjis.length),
                    ),
                  ),
                  const SizedBox(height: 40),
                  KanjiCard(
                    word: kanji,
                    initialFlipped: _isCardFlipped,
                    onUnknown: () async {
                      await _applyAnswer(word: kanji, newStatus: 'dontKnow');
                      if (!mounted) return;
                      if (safeIndex < kanjis.length - 1) {
                        setState(() {
                          _currentIndex = safeIndex + 1;
                          _isCardFlipped = false;
                        });
                      }
                    },
                    onKnown: () async {
                      await _applyAnswer(word: kanji, newStatus: 'know');
                      if (!mounted) return;
                      if (safeIndex < kanjis.length - 1) {
                        setState(() {
                          _currentIndex = safeIndex + 1;
                          _isCardFlipped = false;
                        });
                      }
                    },
                    onPrevious: safeIndex > 0
                        ? () => setState(() {
                              _currentIndex = safeIndex - 1;
                              _isCardFlipped = true;
                            })
                        : null,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeakStatCounter {
  int know;
  int dontKnow;

  _WeakStatCounter({required this.know, required this.dontKnow});

  factory _WeakStatCounter.fromMap(dynamic data) {
    final map = data as Map<String, dynamic>?;
    return _WeakStatCounter(
      know: (map?['know'] as num?)?.toInt() ?? 0,
      dontKnow: (map?['dontKnow'] as num?)?.toInt() ?? 0,
    );
  }
}

// ============================================================
// 상단 뒤로가기 + 제목 + 초기화
// ============================================================
class _TopBar extends StatelessWidget {
  final String title;
  final Future<void> Function() onReset;
  final Future<void> Function() onBack;

  const _TopBar({
    required this.title,
    required this.onReset,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await onBack();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.grey),
          onPressed: () async => await onReset(),
        ),
      ],
    );
  }
}

// ============================================================
// 통계 뱃지
// ============================================================
class _StatsBadgeRow extends StatelessWidget {
  final int learnedCount;
  final int knownCount;
  final int unknownCount;
  final int unseenCount;

  const _StatsBadgeRow({
    required this.learnedCount,
    required this.knownCount,
    required this.unknownCount,
    required this.unseenCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatBadge(icon: Icons.add_circle, color: const Color(0xFFFFC107), count: learnedCount),
          const SizedBox(width: 16),
          _StatBadge(icon: Icons.check_circle, color: const Color(0xFF1976D2), count: knownCount),
          const SizedBox(width: 16),
          _StatBadge(icon: Icons.remove_circle, color: const Color(0xFFE64A19), count: unknownCount),
          const SizedBox(width: 16),
          _StatBadge(icon: Icons.visibility_off, color: Colors.grey, count: unseenCount, useCircleBackground: true),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final bool useCircleBackground;

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.count,
    this.useCircleBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        useCircleBackground
            ? Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 14),
              )
            : Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
