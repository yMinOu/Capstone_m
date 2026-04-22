// 공통 단어 플래시카드 위젯
// 학습 화면, 단어장 등 여러 곳에서 재사용 가능
// - 앞면: 일본어 단어만 표시 (탭하면 뒤집기)
// - 뒷면: 의미, 예문, 버튼 (버튼은 옵션)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/services/tts_service.dart';

class WordCard extends StatefulWidget {
  final WordModel word;
  final VoidCallback? onUnknown;  // 몰라요 (없으면 버튼 숨김)
  final VoidCallback? onKnown;    // 알아요  (없으면 버튼 숨김)
  final VoidCallback? onPrevious; // 이전    (없으면 버튼 숨김)
  final bool initialFlipped;      // 처음부터 뒷면으로 시작할지
  final VoidCallback? onTapVocabularySave;

  const WordCard({
    super.key,
    required this.word,
    this.onUnknown,
    this.onKnown,
    this.onPrevious,
    this.initialFlipped = false,
    this.onTapVocabularySave,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> with SingleTickerProviderStateMixin {
  // 플립 애니메이션
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFlipped = false;

  // 뒷면 스크롤
  final ScrollController _scrollController = ScrollController();
  final ScrollController _exampleScrollController = ScrollController();
  bool _showFade = true;
  bool _showExampleFade = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    // 애니메이션 완료 후 리셋 + 상태 업데이트
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlipped = !_isFlipped);
        _flipController.reset();
      }
    });
    _scrollController.addListener(() {
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent;
      if (atBottom != !_showFade) setState(() => _showFade = !atBottom);
    });
    _exampleScrollController.addListener(() {
      final atBottom = _exampleScrollController.position.pixels >=
          _exampleScrollController.position.maxScrollExtent;
      if (atBottom != !_showExampleFade) setState(() => _showExampleFade = !atBottom);
    });
  }

  @override
  void didUpdateWidget(WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) {
      // 단어 바뀌면 initialFlipped에 따라 앞/뒷면으로 이동 (애니메이션 없이 즉시)
      _flipController.reset();
      _isFlipped = widget.initialFlipped;
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      if (_exampleScrollController.hasClients) _exampleScrollController.jumpTo(0);
      setState(() {
        _showFade = true;
        _showExampleFade = true;
      });
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _flipController.dispose();
    _scrollController.dispose();
    _exampleScrollController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
  }

  void _stopAndCall(VoidCallback callback) {
    TtsService.instance.stop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, _) {
        final progress = _flipAnimation.value;
        final angle = progress * pi;

        // 항상 왼쪽 방향으로만 회전
        // progress < 0.5: 현재 보이는 면이 기울어지며 사라짐 (0 → π/2)
        // progress >= 0.5: 다음 면이 왼쪽에서 나타남 (-π/2 → 0)
        // _isFlipped는 애니메이션 완료 후 토글되므로, 전환 중엔 이전 상태 유지
        final bool showFront;
        final double rotateAngle;
        if (progress < 0.5) {
          showFront = !_isFlipped;
          rotateAngle = angle;
        } else {
          showFront = _isFlipped;
          rotateAngle = angle - pi;
        }

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotateAngle),
          alignment: Alignment.center,
          child: showFront ? _buildFront() : _buildBack(),
        );
      },
    );
  }

  // 앞면: 일본어 단어만 (정사각형, 중앙 배치)
  Widget _buildFront() {
    return GestureDetector(
      onTap: _onTap,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
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
              child: Center(
                child: Text(
                  widget.word.content,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 뒷면: 의미, 예문, 버튼
  Widget _buildBack() {
    final word = widget.word;
    return GestureDetector(
      onTap: _onTap,
      child: _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 아이콘 + 발음 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _CardIconButton(
                icon: Icons.menu_book_outlined,
                onTap: widget.onTapVocabularySave,
              ),
              const SizedBox(width: 8),
              _CardIconButton(
                icon: Icons.volume_up_outlined,
                onTap: () => TtsService.instance.speak(word.content),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 일본어 단어
          Center(
            child: Text(
              word.content,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
            ),
          ),

          // 후리가나 · 로마지
          if (word.furigana.isNotEmpty || word.romaji.isNotEmpty)
            Center(
              child: Text(
                word.furigana.isNotEmpty && word.romaji.isNotEmpty
                    ? '${word.furigana} · ${word.romaji}'
                    : word.furigana.isNotEmpty
                        ? word.furigana
                        : word.romaji,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

          const SizedBox(height: 20),

          // 의미: 항상 3칸 높이 고정 + 넘치면 스크롤
          _InfoRow(
            label: '의미',
            content: SizedBox(
              height: 93,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < word.meaning.length; i++)
                          _MeaningItem(index: i + 1, text: word.meaning[i]),
                      ],
                    ),
                  ),
                  if (_showFade)
                    const Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00FFFFFF), Colors.white],
                            ),
                          ),
                          child: SizedBox(height: 32, width: double.infinity),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 예문: 항상 고정 높이 + 넘치면 스크롤 (없으면 라벨 숨기고 빈 공간)
          const SizedBox(height: 8),
          word.examples.isEmpty
              ? const SizedBox(height: 120)
              : _InfoRow(
                  label: '예문',
                  content: SizedBox(
                    height: 120,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _exampleScrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final ex in word.examples)
                                _ExampleItem(example: ex),
                            ],
                          ),
                        ),
                        if (_showExampleFade)
                          const Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0x00FFFFFF), Colors.white],
                                  ),
                                ),
                                child: SizedBox(height: 32, width: double.infinity),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

          const SizedBox(height: 16),

          // 몰라요 / 알아요 / 이전 버튼 (옵션)
          if (widget.onUnknown != null || widget.onKnown != null || widget.onPrevious != null) ...[
            Row(
              children: [
                if (widget.onUnknown != null)
                  Expanded(
                    child: _CardActionButton(
                      label: '몰라요',
                      color: const Color(0xFFE64A19),
                      onTap: () => _stopAndCall(widget.onUnknown!),
                    ),
                  ),
                if (widget.onUnknown != null && widget.onKnown != null)
                  const SizedBox(width: 12),
                if (widget.onKnown != null)
                  Expanded(
                    child: _CardActionButton(
                      label: '알아요',
                      color: const Color(0xFF1976D2),
                      onTap: () => _stopAndCall(widget.onKnown!),
                    ),
                  ),
              ],
            ),
            if (widget.onPrevious != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: _CardActionButton(
                      label: '이전',
                      color: Colors.grey.shade300,
                      textColor: Colors.grey.shade600,
                      onTap: () => _stopAndCall(widget.onPrevious!),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ],
        ],
      ),
    ),
    );
  }
}

// ============================================================
// 카드 공통 컨테이너 (앞/뒷면 동일한 스타일)
// ============================================================
class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

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
        child: child,
      ),
    );
  }
}

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
      child: Text('$index。$text', style: const TextStyle(fontSize: 13)),
    );
  }
}

class _ExampleItem extends StatelessWidget {
  final WordExample example;

  const _ExampleItem({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(example.content, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            example.meaning,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

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
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        Expanded(child: content),
      ],
    );
  }
}

class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CardIconButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color textColor;

  const _CardActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
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
              style: TextStyle(
                color: textColor,
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
