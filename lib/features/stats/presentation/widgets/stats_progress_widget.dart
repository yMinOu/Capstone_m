/// 통계 화면 상단 진행도 카드 위젯.
import 'package:flutter/material.dart';

class StatsProgressWidget extends StatelessWidget {
  final int todayLearnedCount;
  final int totalStudyCount;

  const StatsProgressWidget({
    super.key,
    required this.todayLearnedCount,
    required this.totalStudyCount,
  });

  static const List<int> _milestones = [0, 100, 500, 1000];

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
  Widget build(BuildContext context) {
    final progress = _progressRatio(totalStudyCount).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘 학습한 카드',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$todayLearnedCount',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            '누적 학습 카드',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 14),
          _ProgressBar(progress: progress),
          const SizedBox(height: 18),
          const _ProgressLabels(values: _milestones),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const thumbSize = 22.0;
        final barWidth = constraints.maxWidth;
        final thumbLeft = (barWidth - thumbSize) * progress;

        return SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFF7),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6FA9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              ...List.generate(4, (index) {
                final ratio = index / 3;
                return Positioned(
                  left: (barWidth - thumbSize) * ratio,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF2D8E5),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }),
              Positioned(
                left: thumbLeft,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFF6FA9),
                      width: 3,
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

class _ProgressLabels extends StatelessWidget {
  final List<int> values;

  const _ProgressLabels({
    required this.values,
  });

  String _formatLabel(int value) {
    switch (value) {
      case 0:
        return '0';
      case 100:
        return '100';
      case 500:
        return '500';
      case 1000:
        return '1000';
      default:
        return '$value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((value) {
        return Text(
          _formatLabel(value),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A7A7A),
          ),
        );
      }).toList(),
    );
  }
}