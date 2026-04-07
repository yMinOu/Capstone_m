/// 학습한 단어 탭 리스트 아이템
import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';

class WordListItemWidget extends StatelessWidget {
  const WordListItemWidget({
    super.key,
    required this.word,
    required this.onTap,
  });

  final LearningProgressModel word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusIcon = _buildStatusIcon(word.status);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEAEAEA)),
            ),
          ),
          child: Row(
            children: [
              statusIcon,
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        word.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        word.meaning.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4F6B8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5FF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF8BD0FF)),
                ),
                child: Text(
                  word.subCategory,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2D9CDB),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'know':
        return const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFF3F3F3),
          child: Icon(Icons.thumb_up_alt_outlined, size: 16),
        );
      case 'dontKnow':
        return const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFFBECEC),
          child: Text(
            '?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      default:
        return const SizedBox(width: 28, height: 28);
    }
  }
}