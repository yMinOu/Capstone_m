// ============================================================
// 단어 학습 화면 - 카테고리 선택 후 단어 플래시카드 학습
// 카테고리 목록에서 탭하면 이 화면으로 이동
// ============================================================
// TODO [Firestore 연결 시] 필요한 데이터:
//   - 단어 목록: /word_categories/{categoryId}/words 컬렉션
//   - 통계(전체/아는단어/모르는단어): /users/{uid}/stats/{categoryId}
// ============================================================

import 'package:flutter/material.dart';

class WordStudyScreen extends StatelessWidget {
  final String categoryId;    // 이전 화면에서 전달받은 카테고리 ID
  final String categoryTitle; // 상단 타이틀에 표시할 카테고리 이름

  const WordStudyScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 뒤로가기 + 카테고리 제목
            _TopBar(title: categoryTitle),

            const SizedBox(height: 16),

            // 통계 뱃지 (전체 / 아는 단어 / 모르는 단어)
            // TODO [Firestore 연결 시]: /users/{uid}/stats/{categoryId} 에서 불러오기
            const Center(child: _StatsBadgeRow()),

            const SizedBox(height: 40),

            // 단어 카드 영역
            // TODO [Firestore 연결 시]: /word_categories/{categoryId}/words 에서 단어 목록 불러오기
            //   단어를 한 개씩 표시하고 몰라요/알아요 버튼으로 넘기는 방식으로 구현
            const Expanded(
              child: Align(
                alignment: Alignment(0, -0.7),
                child: _WordCard(),
              ),
            ),

            const SizedBox(height: 24),
          ],
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

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 통계 뱃지 (전체 / 아는 단어 / 모르는 단어)
// ============================================================
// TODO [Firestore 연결 시]: 아래 임시값을 실제 데이터로 교체
//   - totalCount    : 해당 카테고리 전체 단어 수
//   - knownCount    : 사용자가 '알아요' 누른 단어 수
//   - unknownCount  : 사용자가 '몰라요' 누른 단어 수
class _StatsBadgeRow extends StatelessWidget {
  const _StatsBadgeRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 전체 단어 수
          // TODO [Firestore 연결 시]: totalCount 값으로 교체
          _StatBadge(
            icon: Icons.add_circle,
            color: Color(0xFFFFC107),
            count: 215,
          ),
          SizedBox(width: 16),

          // 아는 단어 수
          // TODO [Firestore 연결 시]: knownCount 값으로 교체
          _StatBadge(
            icon: Icons.check_circle,
            color: Color(0xFF4CAF50),
            count: 12,
          ),
          SizedBox(width: 16),

          // 모르는 단어 수
          // TODO [Firestore 연결 시]: unknownCount 값으로 교체
          _StatBadge(
            icon: Icons.remove_circle,
            color: Color(0xFFF44336),
            count: 5,
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

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
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

// ============================================================
// 단어 카드
// ============================================================
// TODO [Firestore 연결 시]: 아래 임시값을 실제 단어 데이터로 교체
//   - wordText    : 일본어 단어
//   - meanings    : 의미 목록 (List<String>)
//   - exampleJp   : 예문 (일본어)
//   - exampleKr   : 예문 번역 (한국어)
class _WordCard extends StatelessWidget {
  const _WordCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 책 아이콘 + 발음 버튼
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _IconButton(icon: Icons.menu_book_outlined),
                SizedBox(width: 8),
                // TODO [기능 추가 시]: 발음 버튼 누르면 TTS 재생
                _IconButton(icon: Icons.volume_up_outlined),
              ],
            ),

            const SizedBox(height: 16),

            // 일본어 단어
            // TODO [Firestore 연결 시]: wordText 값으로 교체
            const Text(
              'あゆむ',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // 의미 영역
            const _InfoRow(
              label: '의미',
              // TODO [Firestore 연결 시]: meanings 리스트로 교체
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MeaningItem(index: 1, text: '걷다'),
                  _MeaningItem(index: 2, text: '나아가다'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 예문 영역
            const _InfoRow(
              label: '예문',
              // TODO [Firestore 연결 시]: exampleJp, exampleKr 값으로 교체
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('彼はゆっくりと道を歩む', style: TextStyle(fontSize: 13)),
                  Text('그는 천천히 길을 걷는다.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 몰라요 / 알아요 버튼
            Row(
              children: [
                // 몰라요 버튼
                // TODO [Firestore 연결 시]: 누르면 unknownCount +1 업데이트
                Expanded(
                  child: _ActionButton(
                    label: '몰라요',
                    color: const Color(0xFFE64A19),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),

                // 알아요 버튼
                // TODO [Firestore 연결 시]: 누르면 knownCount +1 업데이트
                Expanded(
                  child: _ActionButton(
                    label: '알아요',
                    color: const Color(0xFF1976D2),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 의미 항목 (1. 걷다 형식)
class _MeaningItem extends StatelessWidget {
  final int index;
  final String text;

  const _MeaningItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$index。$text',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

// 의미/예문 라벨 + 내용 행
class _InfoRow extends StatelessWidget {
  final String label;
  final Widget content;

  const _InfoRow({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: content),
      ],
    );
  }
}

// 책/발음 아이콘 버튼
class _IconButton extends StatelessWidget {
  final IconData icon;

  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade600),
    );
  }
}

// 몰라요 / 알아요 버튼
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
