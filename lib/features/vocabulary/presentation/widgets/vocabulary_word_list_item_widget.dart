import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';

class VocabularyWordListItemWidget extends StatelessWidget {
  const VocabularyWordListItemWidget({
    super.key,
    required this.word,
    required this.onTap,
    required this.onDelete,
  });

  final WordModel word;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  bool get _isSentence => word.contentType == 'sentence';

  @override
  Widget build(BuildContext context) {
    final statusIcon = _buildStatusIcon(word.status);
    final hasSubCategory = word.subCategory.trim().isNotEmpty;
    final meaningText = _meaningText(word);

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
            crossAxisAlignment:
            _isSentence ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              statusIcon,
              //const SizedBox(width: 8),

              Expanded(
                child: _isSentence
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    if (meaningText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meaningText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4F6B8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                )
                    : Row(
                  children: [
                    Flexible(
                      child: Text(
                        word.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meaningText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4F6B8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (hasSubCategory) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F5FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF8BD0FF),
                    ),
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

              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _meaningText(WordModel word) {
    if (word.meaning.isEmpty) {
      return '';
    }
    return word.meaning.first;
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