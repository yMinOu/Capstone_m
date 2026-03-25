// 공통 단어 플래시카드 위젯

import 'package:flutter/material.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class WordCard extends StatefulWidget {
  final WordModel word;

  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _exampleScrollController = ScrollController();
  bool _showFade = true;
  bool _showExampleFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent;
      if (atBottom != !_showFade) {
        setState(() => _showFade = !atBottom);
      }
    });
    _exampleScrollController.addListener(() {
      final atBottom = _exampleScrollController.position.pixels >=
          _exampleScrollController.position.maxScrollExtent;
      if (atBottom != !_showExampleFade) {
        setState(() => _showExampleFade = !atBottom);
      }
    });
  }

  @override
  void didUpdateWidget(WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) {
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
    _scrollController.dispose();
    _exampleScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 책 아이콘 + 발음 버튼
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CardIconButton(icon: Icons.menu_book_outlined),
                  SizedBox(width: 8),
                  // TODO [기능 추가 시]: 발음 버튼 누르면 TTS 재생
                  _CardIconButton(icon: Icons.volume_up_outlined),
                ],
              ),

              const SizedBox(height: 16),

              // 일본어 단어
              Text(
                word.content,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // 후리가나 · 로마지
              if (word.furigana.isNotEmpty || word.romaji.isNotEmpty)
                Text(
                  word.furigana.isNotEmpty && word.romaji.isNotEmpty
                      ? '${word.furigana} · ${word.romaji}'
                      : word.furigana.isNotEmpty
                          ? word.furigana
                          : word.romaji,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

              const SizedBox(height: 20),

              // 의미 (3개 이하: 그냥 표시 / 4개 이상: 스크롤 + 하단 페이드)
              _InfoRow(
                label: '의미',
                content: word.meaning.length <= 3
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < word.meaning.length; i++)
                            _MeaningItem(index: i + 1, text: word.meaning[i]),
                        ],
                      )
                    : SizedBox(
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
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0x00FFFFFF),
                                          Colors.white,
                                        ],
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

              // 예문 (없으면 숨김)
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 8),
                _InfoRow(
                  label: '예문',
                  content: word.examples.length <= 3
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final ex in word.examples)
                              _ExampleItem(example: ex),
                          ],
                        )
                      : SizedBox(
                          height: 150,
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
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0x00FFFFFF),
                                            Colors.white,
                                          ],
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
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
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
      child: Text(
        '$index。$text',
        style: const TextStyle(fontSize: 13),
      ),
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

class _CardIconButton extends StatelessWidget {
  final IconData icon;

  const _CardIconButton({required this.icon});

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
