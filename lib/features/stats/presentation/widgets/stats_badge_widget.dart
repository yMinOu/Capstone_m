/// 통계 화면에서 사용할 학습 뱃지 위젯.
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFD9D9D9),
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _StatsBadgeItem(
                  imagePath: totalStudyCount > 0
                      ? 'assets/images/stats/Badge1.png'
                      : 'assets/images/stats/Badge1_1.png',
                  label: '첫 학습 완료',
                  borderColor: totalStudyCount > 0
                      ? const Color(0xFFFF6FA9)
                      : const Color(0xFFD9D9D9),
                ),
              ),
              Expanded(
                child: _StatsBadgeItem(
                  imagePath: streakDays >= 7
                      ? 'assets/images/stats/Badge2.png'
                      : 'assets/images/stats/Badge2_1.png',
                  label: '7일 연속 학습',
                  borderColor: streakDays >= 7
                      ? const Color(0xFFD4A5FF)
                      : const Color(0xFFD9D9D9),
                ),
              ),
              Expanded(
                child: _StatsBadgeItem(
                  imagePath: totalStudyCount >= 100
                      ? 'assets/images/stats/Badge3.png'
                      : 'assets/images/stats/Badge3_1.png',
                  label: '100단어 마스터',
                  borderColor: totalStudyCount >= 100
                      ? const Color(0xFFF2C94C)
                      : const Color(0xFFD9D9D9),
                ),
              ),
              Expanded(
                child: _StatsBadgeItem(
                  imagePath: totalStudySeconds >= 36000
                      ? 'assets/images/stats/Badge4.png'
                      : 'assets/images/stats/Badge4_1.png',
                  label: '10시간 학습',
                  borderColor: totalStudySeconds >= 36000
                      ? const Color(0xFF5B8CFF)
                      : const Color(0xFFD9D9D9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsBadgeItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color borderColor;

  const _StatsBadgeItem({
    required this.imagePath,
    required this.label,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(10),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}