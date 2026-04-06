// 예문 플래시카드 위젯
// 로마지 / 한국어 뜻은 블러 처리 → 각각 탭하면 공개

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class SentenceCard extends StatefulWidget {
  final WordModel sentence;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTapVocabularySave;

  const SentenceCard({
    super.key,
    required this.sentence,
    this.onPrevious,
    this.onNext,
    this.onTapVocabularySave,
  });

  @override
  State<SentenceCard> createState() => _SentenceCardState();
}

class _SentenceCardState extends State<SentenceCard> {
  bool _showRomaji = false;
  bool _showMeaning = false;

  @override
  void didUpdateWidget(SentenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 예문 바뀌면 블러 리셋
    if (oldWidget.sentence.id != widget.sentence.id) {
      setState(() {
        _showRomaji = false;
        _showMeaning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meaning = widget.sentence.meaning.isNotEmpty
        ? widget.sentence.meaning.first
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
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
          children: [
            // 상단 흰 영역: 아이콘 + 일본어 + 로마지
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 210),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 책 아이콘 + 발음 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _IconButton(
                          icon: Icons.menu_book_outlined,
                          onTap: widget.onTapVocabularySave,
                        ),
                        const SizedBox(width: 8),
                        // TODO [기능 추가 시]: TTS 재생
                        _IconButton(icon: Icons.volume_up_outlined),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 일본어 예문
                    Text(
                      widget.sentence.content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),

                    // 로마지 (탭하면 블러 해제)
                    if (widget.sentence.romaji.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showRomaji = !_showRomaji),
                        child: _BlurableText(
                          text: widget.sentence.romaji,
                          blurred: !_showRomaji,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 파란 영역: 한국어 뜻 (탭하면 블러 해제, 상단과 동일 크기)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 210),
              child: GestureDetector(
                onTap: () => setState(() => _showMeaning = !_showMeaning),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F1FB),
                  ),
                  child: Center(
                    child: _BlurableText(
                      text: meaning,
                      blurred: !_showMeaning,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 이전 / 다음 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _NavButton(
                      label: '이전',
                      color: const Color(0xFFE64A19),
                      onTap: widget.onPrevious,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavButton(
                      label: '다음',
                      color: const Color(0xFF1976D2),
                      onTap: widget.onNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 블러 처리 가능한 텍스트 위젯
class _BlurableText extends StatelessWidget {
  final String text;
  final bool blurred;
  final TextStyle style;

  const _BlurableText({
    required this.text,
    required this.blurred,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: blurred
          ? ImageFiltered(
              key: const ValueKey('blurred'),
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Text(text, textAlign: TextAlign.center, style: style),
            )
          : Text(
              key: const ValueKey('visible'),
              text,
              textAlign: TextAlign.center,
              style: style,
            ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _NavButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: disabled ? Colors.grey.shade200 : color,
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
                color: disabled ? Colors.grey.shade400 : Colors.white,
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

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({
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
