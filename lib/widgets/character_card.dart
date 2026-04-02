// 히라가나 / 가타카나 플래시카드 위젯
// 앞면: 문자만 표시 (탭하면 뒤집기)
// 뒷면: 한국어 발음 + 몰라요/알아요 버튼

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class CharacterCard extends StatefulWidget {
  final WordModel character;
  final bool initialFlipped;
  final VoidCallback onUnknown;
  final VoidCallback onKnown;
  final VoidCallback? onPrevious;

  const CharacterCard({
    super.key,
    required this.character,
    required this.initialFlipped,
    required this.onUnknown,
    required this.onKnown,
    this.onPrevious,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFlipped = false;

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

    if (widget.initialFlipped) {
      _isFlipped = true;
    }
  }

  @override
  void didUpdateWidget(CharacterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character.id != widget.character.id) {
      _flipController.reset();
      _isFlipped = widget.initialFlipped;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_flipController.isAnimating) return;
    _flipController.forward();
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

  // 앞면: 문자만
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
                  widget.character.content,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 뒷면: 아이콘 + 문자 + 발음 + 버튼
  Widget _buildBack() {
    final reading = widget.character.pronunciationKr.isNotEmpty
        ? widget.character.pronunciationKr
        : (widget.character.meaning.isNotEmpty
            ? widget.character.meaning.first
            : '');

    return GestureDetector(
      onTap: _onTap,
      child: Padding(
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
              // 아이콘
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _IconBtn(icon: Icons.menu_book_outlined),
                  const SizedBox(width: 8),
                  _IconBtn(icon: Icons.volume_up_outlined),
                ],
              ),

              const SizedBox(height: 16),

              // 문자
              Text(
                widget.character.content,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // 한국어 발음
              if (reading.isNotEmpty)
                Text(
                  reading,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

              const SizedBox(height: 28),

              // 몰라요 / 알아요
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '몰라요',
                      color: const Color(0xFFE64A19),
                      onTap: widget.onUnknown,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: '알아요',
                      color: const Color(0xFF1976D2),
                      onTap: widget.onKnown,
                    ),
                  ),
                ],
              ),

              // 이전 버튼
              if (widget.onPrevious != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: '이전',
                        color: Colors.grey.shade300,
                        textColor: Colors.grey.shade600,
                        onTap: widget.onPrevious!,
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final Color textColor;

  const _ActionButton({
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
