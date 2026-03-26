// ============================================================
// 단어 학습 화면 - Firestore에서 레벨별 단어를 불러와 플래시카드로 표시
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/data/repositories/learning_progress_repository.dart';
import 'package:nihongo/features/learning/data/repositories/study_stats_repository.dart';
import 'package:nihongo/features/learning/data/repositories/user_repository.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';

import 'package:nihongo/widgets/word_card.dart';

class WordStudyScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryTitle;
  const WordStudyScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  ConsumerState<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends ConsumerState<WordStudyScreen> {
  int _currentIndex = 0;
  bool _isCardFlipped = false;
  int _knownCount = 0;
  int _unknownCount = 0;
  int _learnedCount = 0;
  // wordId → 'know' | 'dontKnow' : 이전 답변 추적용
  final Map<String, String> _wordAnswers = {};
  DateTime? _studyStartTime;
  String? _uid;
  UserRepository? _userRepository;
  StudyStatsRepository? _studyStatsRepository;
  LearningProgressRepository? _learningProgressRepository;

  @override
  void initState() {
    super.initState();
    _studyStartTime = DateTime.now();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _userRepository = ref.read(userRepositoryProvider);
    _studyStatsRepository = ref.read(studyStatsRepositoryProvider);
    _learningProgressRepository = ref.read(learningProgressRepositoryProvider);
    _loadInitialProgress();
    if (_uid != null) _userRepository!.updateStreakIfNeeded(_uid!);
    print('[학습타이머] 시작 - uid: $_uid');
  }

  // TODO [임시]: 개발 테스트용 초기화 - 배포 전 제거할 것
  Future<void> _resetProgress() async {
    if (_uid == null) return;
    await _learningProgressRepository!.resetProgress(
      uid: _uid!,
      subCategory: widget.categoryId,
    );
    setState(() {
      _knownCount = 0;
      _unknownCount = 0;
      _currentIndex = 0;
      _wordAnswers.clear();
    });
  }

  // 알아요/몰라요 답변 처리 - 이전 답변이 있으면 카운트 교체
  void _applyAnswer({required WordModel word, required String newStatus}) {
    final prev = _wordAnswers[word.id];
    if (prev == newStatus) return; // 같은 답변이면 무시

    setState(() {
      // 이전 답변 카운트 취소
      if (prev == 'know') _knownCount--;
      if (prev == 'dontKnow') _unknownCount--;

      // 새 답변 카운트 적용
      if (newStatus == 'know') _knownCount++;
      if (newStatus == 'dontKnow') _unknownCount++;

      // 처음 답변이면 학습 수 증가
      if (prev == null) _learnedCount++;

      _wordAnswers[word.id] = newStatus;
    });

    if (_uid != null) {
      if (prev == null) {
        _userRepository!.incrementStudyCount(_uid!);
        _studyStatsRepository!.incrementDailyLearnedCount(_uid!);
      }
      _learningProgressRepository!.updateStatus(
        uid: _uid!,
        word: word,
        status: newStatus,
      );
    }
  }

  // 화면 진입 시 기존 학습 기록 불러오기
  Future<void> _loadInitialProgress() async {
    if (_uid == null) return;
    final results = await Future.wait([
      _learningProgressRepository!.getProgressCount(
        uid: _uid!,
        subCategory: widget.categoryId,
      ),
      _studyStatsRepository!.getDailyLearnedCount(_uid!),
    ]);
    final progress = results[0] as ({int knownCount, int unknownCount, Map<String, String> wordAnswers});
    final learnedCount = results[1] as int;
    setState(() {
      _knownCount = progress.knownCount;
      _unknownCount = progress.unknownCount;
      _learnedCount = learnedCount;
      _wordAnswers.addAll(progress.wordAnswers);
    });
  }

  @override
  void dispose() {
    if (_uid != null && _studyStartTime != null) {
      final seconds = DateTime.now().difference(_studyStartTime!).inSeconds;
      print('[학습타이머] 종료 - 경과: ${seconds}초, uid: $_uid');
      if (seconds > 0) {
        _userRepository!.addStudySeconds(_uid!, seconds)
            .then((_) => print('[학습타이머] Firestore 저장 완료'))
            .catchError((e) => print('[학습타이머] Firestore 에러: $e'));
        _studyStatsRepository!.addDailyStudySeconds(_uid!, seconds);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncWords = ref.watch(wordListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: asyncWords.when(
          loading: () => Column(
            children: [
              _TopBar(title: widget.categoryTitle, onReset: _resetProgress),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _TopBar(title: widget.categoryTitle, onReset: _resetProgress),
              Expanded(
                child: Center(
                  child: Text(
                    '단어를 불러오지 못했어요\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          data: (words) {
            if (words.isEmpty) {
              return Column(
                children: [
                  _TopBar(title: widget.categoryTitle, onReset: _resetProgress),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '단어가 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            final safeIndex = _currentIndex.clamp(0, words.length - 1);
            final word = words[safeIndex];

            return SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: widget.categoryTitle, onReset: _resetProgress),

                const SizedBox(height: 16),

                Center(
                  child: _StatsBadgeRow(
                    learnedCount: _learnedCount,
                    knownCount: _knownCount,
                    unknownCount: _unknownCount,
                    unseenCount: (words.length - _knownCount - _unknownCount).clamp(0, words.length),
                  ),
                ),

                const SizedBox(height: 40),

                // 플립 카드 (앞면: 단어만 / 뒷면: 전체 정보 + 버튼)
                WordCard(
                  word: word,
                  initialFlipped: _isCardFlipped,
                  onUnknown: () {
                    _applyAnswer(word: word, newStatus: 'dontKnow');
                    if (safeIndex < words.length - 1) {
                      setState(() {
                        _currentIndex = safeIndex + 1;
                        _isCardFlipped = false;
                      });
                    }
                  },
                  onKnown: () {
                    _applyAnswer(word: word, newStatus: 'know');
                    if (safeIndex < words.length - 1) {
                      setState(() {
                        _currentIndex = safeIndex + 1;
                        _isCardFlipped = false;
                      });
                    }
                  },
                  onPrevious: safeIndex > 0
                      ? () => setState(() {
                          _currentIndex = safeIndex - 1;
                          _isCardFlipped = true; // 이전은 뒷면에서만 누를 수 있으므로 항상 뒷면으로
                        })
                      : null,
                ),

                const SizedBox(height: 24),
              ],
            ));
          },
        ),
      ),
    );
  }
}

// ============================================================
// 상단 뒤로가기 + 제목
// ============================================================
class _TopBar extends StatelessWidget {
  final String title;
  // TODO [임시]: 개발 테스트용 초기화 콜백 - 배포 전 제거할 것
  final VoidCallback onReset;

  const _TopBar({required this.title, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // TODO [임시]: 개발 테스트용 초기화 버튼 - 배포 전 제거할 것
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.grey),
          onPressed: onReset,
        ),
      ],
    );
  }
}

// ============================================================
// 통계 뱃지 (학습 수 / 아는 단어 / 모르는 단어 / 안 본 단어)
// ============================================================
class _StatsBadgeRow extends StatelessWidget {
  final int learnedCount;  // 알아요 + 몰라요 합계
  final int knownCount;    // 알아요
  final int unknownCount;  // 몰라요
  final int unseenCount;   // 아직 안 본 단어

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
          _StatBadge(
            icon: Icons.add_circle,
            color: const Color(0xFFFFC107),
            count: learnedCount,
          ),
          const SizedBox(width: 16),
          _StatBadge(
            icon: Icons.check_circle,
            color: const Color(0xFF1976D2),
            count: knownCount,
          ),
          const SizedBox(width: 16),
          _StatBadge(
            icon: Icons.remove_circle,
            color: const Color(0xFFE64A19),
            count: unknownCount,
          ),
          const SizedBox(width: 16),
          _StatBadge(
            icon: Icons.visibility_off,
            color: Colors.grey,
            count: unseenCount,
            useCircleBackground: true,
          ),
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
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              )
            : Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

