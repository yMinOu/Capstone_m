/// 통계 화면에서 사용할 학습 뱃지 위젯.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StatsBadgeWidget extends StatelessWidget {
  final int streakDays;
  final int totalStudyCount;
  final int totalStudySeconds;

  const StatsBadgeWidget({
    super.key,
    required this.streakDays,
    required this.totalStudyCount,
    required this.totalStudySeconds,
  });

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData(
        imagePath: totalStudyCount > 0
            ? 'assets/images/stats/Badge1.png'
            : 'assets/images/stats/Badge1_1.png',
        label: '첫 학습 완료',
        borderColor: totalStudyCount > 0
            ? const Color(0xFFFF6FA9)
            : const Color(0xFFD9D9D9),
      ),
      _BadgeData(
        imagePath: streakDays >= 7
            ? 'assets/images/stats/Badge2.png'
            : 'assets/images/stats/Badge2_1.png',
        label: '7일 연속 학습',
        borderColor: streakDays >= 7
            ? const Color(0xFFD4A5FF)
            : const Color(0xFFD9D9D9),
      ),
      _BadgeData(
        imagePath: totalStudyCount >= 100
            ? 'assets/images/stats/Badge3.png'
            : 'assets/images/stats/Badge3_1.png',
        label: '100단어 마스터',
        borderColor: totalStudyCount >= 100
            ? const Color(0xFFF2C94C)
            : const Color(0xFFD9D9D9),
      ),
      _BadgeData(
        imagePath: totalStudySeconds >= 36000
            ? 'assets/images/stats/Badge4.png'
            : 'assets/images/stats/Badge4_1.png',
        label: '10시간 학습',
        borderColor: totalStudySeconds >= 36000
            ? const Color(0xFF5B8CFF)
            : const Color(0xFFD9D9D9),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 뱃지',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;

              // 한 줄 4개가 너무 좁으면 2줄 2개씩
              final isSmallScreen = constraints.maxWidth < 360;
              final itemsPerRow = isSmallScreen ? 2 : 4;

              final itemWidth =
                  (constraints.maxWidth - (spacing * (itemsPerRow - 1))) /
                      itemsPerRow;

              final badgeSize = math.min(76.0, itemWidth * 0.72);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: badges.map((badge) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _StatsBadgeItem(
                        imagePath: badge.imagePath,
                        label: badge.label,
                        borderColor: badge.borderColor,
                        badgeSize: 76, // 고정 or 살짝 줄여도 됨
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String imagePath;
  final String label;
  final Color borderColor;

  _BadgeData({
    required this.imagePath,
    required this.label,
    required this.borderColor,
  });
}

class _StatsBadgeItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color borderColor;
  final double badgeSize;

  const _StatsBadgeItem({
    required this.imagePath,
    required this.label,
    required this.borderColor,
    required this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    final imagePadding = badgeSize * 0.13;
    final fontSize = badgeSize < 64 ? 11.5 : 13.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: badgeSize,
          height: badgeSize,
          padding: EdgeInsets.all(imagePadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}