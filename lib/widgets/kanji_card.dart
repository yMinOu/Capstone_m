// 한자 플래시카드 위젯
// - 앞면: 한자만 표시 (탭하면 뒤집기)
// - 뒷면: 의미, 훈독, 음독, 예시, 버튼

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/services/tts_service.dart';

class KanjiCard extends StatefulWidget {
  final WordModel word;
  final VoidCallback? onUnknown;
  final VoidCallback? onKnown;
  final VoidCallback? onPrevious;
  final bool initialFlipped;
  final VoidCallback? onTapVocabularySave;

  const KanjiCard({
    super.key,
    required this.word,
    this.onUnknown,
    this.onKnown,
    this.onPrevious,
    this.initialFlipped = false,
    this.onTapVocabularySave,
  });

  @override
  State<KanjiCard> createState() => _KanjiCardState();
}

class _KanjiCardState extends State<KanjiCard> with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFlipped = false;

  final ScrollController _meaningScrollController = ScrollController();
  final ScrollController _exampleScrollController = ScrollController();
  bool _showMeaningFade = true;
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
    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlipped = !_isFlipped);
        _flipController.reset();
      }
    });
    _meaningScrollController.addListener(() {
      final atBottom = _meaningScrollController.position.pixels >=
          _meaningScrollController.position.maxScrollExtent;
      if (atBottom != !_showMeaningFade) setState(() => _showMeaningFade = !atBottom);
    });
    _exampleScrollController.addListener(() {
      final atBottom = _exampleScrollController.position.pixels >=
          _exampleScrollController.position.maxScrollExtent;
      if (atBottom != !_showExampleFade) setState(() => _showExampleFade = !atBottom);
    });
  }

  @override
  void didUpdateWidget(KanjiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) {
      _flipController.reset();
      _isFlipped = widget.initialFlipped;
      if (_meaningScrollController.hasClients) _meaningScrollController.jumpTo(0);
      if (_exampleScrollController.hasClients) _exampleScrollController.jumpTo(0);
      setState(() {
        _showMeaningFade = true;
        _showExampleFade = true;
      });
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _flipController.dispose();
    _meaningScrollController.dispose();
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
                    fontSize: 72,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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

            // 한자
            Center(
              child: Text(
                word.content,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
              ),
            ),

            const SizedBox(height: 20),

            // 의미
            _InfoRow(
              label: '의미',
              content: word.meaning.length <= 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < word.meaning.length; i++)
                          _MeaningItem(index: i + 1, text: word.meaning[i]),
                        const SizedBox(height: 31),
                      ],
                    )
                  : SizedBox(
                      height: 93,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _meaningScrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < word.meaning.length; i++)
                                  _MeaningItem(index: i + 1, text: word.meaning[i]),
                              ],
                            ),
                          ),
                          if (_showMeaningFade)
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
                                  child: SizedBox(height: 24, width: double.infinity),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 8),

            // 훈독
            if (word.furigana.isNotEmpty)
              _InfoRow(
                label: '훈독',
                content: _ReadingItem(text: word.furigana),
              ),

            const SizedBox(height: 8),

            // 음독
            if (word.romaji.isNotEmpty)
              _InfoRow(
                label: '음독',
                content: _ReadingItem(text: word.romaji),
              ),

            const SizedBox(height: 8),

            // 예시
            word.examples.isEmpty
                ? const SizedBox(height: 120)
                : _InfoRow(
                    label: '예시',
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
                                  child: SizedBox(height: 24, width: double.infinity),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 16),

            // 몰라요 / 알아요 / 이전 버튼
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

class _ReadingItem extends StatelessWidget {
  final String text;
  const _ReadingItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
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
