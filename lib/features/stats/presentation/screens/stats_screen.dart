/// 학습 통계를 보여주는 화면.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';
import 'package:nihongo/features/stats/presentation/providers/stats_providers.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_card_widget.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_chart_widget.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_badge_widget.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_weak_area_widget.dart';

class StatsScreen extends ConsumerWidget {
  final int animationSeed;
  final bool isActive;

  const StatsScreen({
    super.key,
    this.animationSeed = 0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final selectedPeriod = ref.watch(statsChartPeriodProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) => _StatsContent(
            stats: stats,
            animationSeed: animationSeed,
            selectedPeriod: selectedPeriod,
            onPeriodChanged: (period) {
              ref.read(statsChartPeriodProvider.notifier).state = period;
            },
            isActive: isActive,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              '통계 데이터를 불러오지 못했어요.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final StatsModel stats;
  final int animationSeed;
  final StatsChartPeriod selectedPeriod;
  final ValueChanged<StatsChartPeriod> onPeriodChanged;
  final bool isActive;

  const _StatsContent({
    required this.stats,
    required this.animationSeed,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (stats.totalStudySeconds / 60).floor();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatsTopVideoSection(
            todayLearnedCount: stats.learnedCount,
            totalStudyCount: stats.totalStudyCount,
            isActive: isActive,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatsCardWidget(
                        title: '전체 학습 시간',
                        value: '$totalMinutes',
                        unit: '분',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatsCardWidget(
                        title: '연속 학습일',
                        value: '${stats.streakDays}',
                        unit: '일',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StatsChartWidget(
                  animationSeed: animationSeed,
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: onPeriodChanged,
                  dailyItems: stats.dailyChart,
                  weeklyItems: stats.weeklyChart,
                  monthlyItems: stats.monthlyChart,
                ),
                const SizedBox(height: 16),
                StatsWeakAreaWidget(
                  key: ValueKey('weak_area_$animationSeed'),
                  animationSeed: animationSeed,
                  items: stats.weakAreas,
                  message: stats.weakAreaMessage,
                ),
                const SizedBox(height: 16),
                StatsBadgeWidget(
                  streakDays: stats.streakDays,
                  totalStudyCount: stats.totalStudyCount,
                  totalStudySeconds: stats.totalStudySeconds,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsTopVideoSection extends StatefulWidget {
  final int todayLearnedCount;
  final int totalStudyCount;
  final bool isActive;

  const StatsTopVideoSection({
    super.key,
    required this.todayLearnedCount,
    required this.totalStudyCount,
    required this.isActive,
  });

  @override
  State<StatsTopVideoSection> createState() => _StatsTopVideoSectionState();
}

class _StatsTopVideoSectionState extends State<StatsTopVideoSection> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _showCurrentTotalStudyCountBubble = false;

  static const List<int> _milestones = [0, 100, 500, 1000];

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/images/stats/cat_video.mp4',
    );

    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant StatsTopVideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isInitialized) return;

    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }

    if (oldWidget.totalStudyCount != widget.totalStudyCount &&
        _showCurrentTotalStudyCountBubble) {
      setState(() {
        _showCurrentTotalStudyCountBubble = false;
      });
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0);

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      _syncPlayback();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _syncPlayback() {
    if (!_controller.value.isInitialized) return;

    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  double _progressRatio(int value) {
    if (value <= _milestones.first) {
      return 0;
    }

    if (value >= _milestones.last) {
      return 1;
    }

    for (int i = 0; i < _milestones.length - 1; i++) {
      final start = _milestones[i];
      final end = _milestones[i + 1];

      if (value >= start && value <= end) {
        final localRatio = (value - start) / (end - start);
        return (i + localRatio) / (_milestones.length - 1);
      }
    }

    return 0;
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressRatio(widget.totalStudyCount).clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF3F6),
                  Color(0xFFDFDFDF),
                  Color(0xFFEAEAEA),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.3, 0.6, 0.85, 1.0],
              ),
            ),
          ),
          if (_isInitialized)
            Positioned.fill(
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.08, 0.95, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.8,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0xFFFFF3F6),
              ),
            ),
          IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xCCFFF3F6),
                          Color(0x66FFF3F6),
                          Color(0x00FFF3F6),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0x66FFFFFF),
                          Color(0xCCFFFFFF),
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            top: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  '오늘 학습한 카드',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.todayLearnedCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '개',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '누적 학습 카드',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                _OverlayProgressBar(
                  progress: progress,
                  totalStudyCount: widget.totalStudyCount,
                  showCurrentCountBubble: _showCurrentTotalStudyCountBubble,
                  onCurrentThumbTap: () {
                    setState(() {
                      _showCurrentTotalStudyCountBubble =
                      !_showCurrentTotalStudyCountBubble;
                    });
                  },
                ),
                const SizedBox(height: 5),
                _MilestoneLabels(values: _milestones),
              ],
            ),
          ),
          if (!_isInitialized && _errorMessage == null)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '영상 로드 실패\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

  }
}

class _MilestoneLabels extends StatelessWidget {
  final List<int> values;

  const _MilestoneLabels({
    required this.values,
  });

  String _formatLabel(int value) => '$value';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbSize = 12.0;
        final barWidth = constraints.maxWidth;

        return SizedBox(
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(values.length, (index) {
              final ratio =
              values.length == 1 ? 0.0 : index / (values.length - 1);
              final centerX =
                  (barWidth - thumbSize) * ratio + (thumbSize / 2);

              return Positioned(
                left: centerX,
                bottom: 0,
                child: Transform.translate(
                  offset: const Offset(-0.5, -5),
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: Text(
                      _formatLabel(values[index]),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _OverlayProgressBar extends StatelessWidget {
  final double progress;
  final int totalStudyCount;
  final bool showCurrentCountBubble;
  final VoidCallback onCurrentThumbTap;

  const _OverlayProgressBar({
    required this.progress,
    required this.totalStudyCount,
    required this.showCurrentCountBubble,
    required this.onCurrentThumbTap,
  });

  @override
  Widget build(BuildContext context) {
    const milestones = [0, 100, 500, 1000];
    const thumbSize = 12.0;
    const touchSize = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final clampedProgress = progress.clamp(0.0, 1.0);
        final thumbLeft = (barWidth - thumbSize) * clampedProgress;
        final thumbCenter = thumbLeft + (thumbSize / 2);

        final bubbleText = '$totalStudyCount';
        final bubbleWidth = (bubbleText.length * 8.5 + 20.0).clamp(34.0, 64.0);
        final bubbleLeft =
        (thumbCenter - (bubbleWidth / 2)).clamp(0.0, barWidth - bubbleWidth);

        return SizedBox(
          height: 15,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0x66FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: barWidth * clampedProgress,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8989),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              ...List.generate(milestones.length, (index) {
                final ratio = index / (milestones.length - 1);
                return Positioned(
                  left: (barWidth - thumbSize) * ratio,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFCCCC),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                left: thumbLeft - ((touchSize - thumbSize) / 2),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onCurrentThumbTap,
                  child: SizedBox(
                    width: touchSize,
                    height: touchSize,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFF8989),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          if (showCurrentCountBubble)
                            Positioned(
                              top: 16,
                              left: -(bubbleWidth / 2) + (touchSize / 2),
                              child: IgnorePointer(
                                child: Container(
                                  width: bubbleWidth,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFFFF8989),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    bubbleText,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}