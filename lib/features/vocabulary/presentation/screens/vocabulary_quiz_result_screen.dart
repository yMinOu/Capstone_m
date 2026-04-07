/// 역할: 단어장 퀴즈 결과와 틀린 단어 목록을 보여주는 화면입니다.
import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';

class VocabularyQuizResultScreen extends StatelessWidget {
  const VocabularyQuizResultScreen({
    super.key,
    required this.vocabularyTitle,
    required this.totalCount,
    required this.correctCount,
    required this.wrongWords,
  });

  final String vocabularyTitle;
  final int totalCount;
  final int correctCount;
  final List<WordModel> wrongWords;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          '퀴즈',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalCount문제 중 $correctCount개를 맞췄어요!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (wrongWords.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '틀린 단어 ${wrongWords.length}개',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 260),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE1E1E1)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: wrongWords.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: Color(0xFFEAEAEA),
                            ),
                            itemBuilder: (context, index) {
                              final word = wrongWords[index];
                              final meaningText = word.meaning.isEmpty
                                  ? ''
                                  : word.meaning.join(', ');

                              return ListTile(
                                dense: true,
                                title: Text(
                                  word.content,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: meaningText.isEmpty
                                    ? null
                                    : Text(
                                  meaningText,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4F6B8A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFBEBEBE)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '단어장으로 이동',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}