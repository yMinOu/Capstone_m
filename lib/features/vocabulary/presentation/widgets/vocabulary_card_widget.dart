/// 단어장 카드 위젯
import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';

class VocabularyCardWidget extends StatelessWidget {
  const VocabularyCardWidget({
    super.key,
    required this.vocabulary,
    required this.onDelete,
    required this.onTap,
  });

  final VocabularyModel vocabulary;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final createdAtText =
        '${vocabulary.createdAt.year.toString().padLeft(4, '0')}-'
        '${vocabulary.createdAt.month.toString().padLeft(2, '0')}-'
        '${vocabulary.createdAt.day.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD9D9D9),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_book_outlined,
                  size: 30,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vocabulary.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                      ),
                      if ((vocabulary.description ?? '').trim().isNotEmpty) ...[
                        Text(
                          vocabulary.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A9A9A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        '${vocabulary.wordCount}개 단어 · $createdAtText',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A9A9A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFF8F8F8F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}