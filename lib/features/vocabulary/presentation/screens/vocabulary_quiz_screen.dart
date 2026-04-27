/// 역할: 단어장 단어들로 좌우 매칭형 퀴즈를 진행하는 화면입니다.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_quiz_result_screen.dart';

class VocabularyQuizScreen extends StatefulWidget {
  const VocabularyQuizScreen({
    super.key,
    required this.words,
    required this.vocabularyTitle,
  });

  final List<WordModel> words;
  final String vocabularyTitle;

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  static const int _groupSize = 4;

  late final List<WordModel> _allWords;
  late final List<List<WordModel>> _wordGroups;

  int _currentGroupIndex = 0;
  int _matchedWordCount = 0;
  int _correctCount = 0;

  String? _selectedJapaneseWordId;
  bool _isProcessingSelection = false;

  final Set<String> _matchedIdsInCurrentGroup = <String>{};
  final Set<String> _wrongWordIds = <String>{};

  String? _flashJapaneseId;
  String? _flashMeaningWordId;
  bool? _flashIsCorrect;

  late List<WordModel> _currentMeaningOptions;

  @override
  void initState() {
    super.initState();

    _allWords = widget.words
        .where(
          (word) =>
      word.content.trim().isNotEmpty &&
          word.meaning.isNotEmpty &&
          word.meaning.join().trim().isNotEmpty,
    )
        .toList();

    _wordGroups = _buildWordGroups(_allWords);

    if (_wordGroups.isNotEmpty) {
      _currentMeaningOptions = List<WordModel>.from(_wordGroups.first)..shuffle();
    } else {
      _currentMeaningOptions = <WordModel>[];
    }
  }

  List<List<WordModel>> _buildWordGroups(List<WordModel> words) {
    final shuffledWords = List<WordModel>.from(words)..shuffle();
    final groups = <List<WordModel>>[];

    for (int i = 0; i < shuffledWords.length; i += _groupSize) {
      final end = (i + _groupSize < shuffledWords.length)
          ? i + _groupSize
          : shuffledWords.length;
      groups.add(shuffledWords.sublist(i, end));
    }

    return groups;
  }

  List<WordModel> get _currentGroup {
    if (_wordGroups.isEmpty) {
      return <WordModel>[];
    }
    return _wordGroups[_currentGroupIndex];
  }

  String _meaningText(WordModel word) {
    if (word.meaning.isEmpty) {
      return '';
    }
    return word.meaning.join(', ');
  }

  Future<void> _onTapJapanese(WordModel word) async {
    if (_isProcessingSelection) {
      return;
    }
    if (_matchedIdsInCurrentGroup.contains(word.id)) {
      return;
    }

    setState(() {
      _selectedJapaneseWordId = word.id;
    });
  }

  Future<void> _onTapMeaning(WordModel meaningWord) async {
    if (_isProcessingSelection) {
      return;
    }
    if (_selectedJapaneseWordId == null) {
      return;
    }
    if (_matchedIdsInCurrentGroup.contains(meaningWord.id)) {
      return;
    }

    final selectedJapaneseWord = _currentGroup.firstWhere(
          (word) => word.id == _selectedJapaneseWordId,
    );

    final isCorrect = selectedJapaneseWord.id == meaningWord.id;

    setState(() {
      _isProcessingSelection = true;
      _flashJapaneseId = selectedJapaneseWord.id;
      _flashMeaningWordId = meaningWord.id;
      _flashIsCorrect = isCorrect;
    });

    if (!isCorrect) {
      _wrongWordIds.add(selectedJapaneseWord.id);
    }

    await Future<void>.delayed(const Duration(milliseconds: 420));

    if (!mounted) {
      return;
    }

    if (isCorrect) {
      final isFirstTryCorrect = !_wrongWordIds.contains(selectedJapaneseWord.id);

      setState(() {
        _matchedIdsInCurrentGroup.add(selectedJapaneseWord.id);
        _matchedWordCount += 1;
        if (isFirstTryCorrect) {
          _correctCount += 1;
        }
      });

      final isGroupCompleted =
          _matchedIdsInCurrentGroup.length == _currentGroup.length;

      if (isGroupCompleted) {
        await Future<void>.delayed(const Duration(milliseconds: 220));

        if (!mounted) {
          return;
        }

        final isLastGroup = _currentGroupIndex == _wordGroups.length - 1;

        if (isLastGroup) {
          final wrongWords = _allWords
              .where((word) => _wrongWordIds.contains(word.id))
              .toList();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VocabularyQuizResultScreen(
                vocabularyTitle: widget.vocabularyTitle,
                totalCount: _allWords.length,
                correctCount: _correctCount,
                wrongWords: wrongWords,
              ),
            ),
          );
          return;
        }

        setState(() {
          _currentGroupIndex += 1;
          _matchedIdsInCurrentGroup.clear();
          _selectedJapaneseWordId = null;
          _flashJapaneseId = null;
          _flashMeaningWordId = null;
          _flashIsCorrect = null;
          _isProcessingSelection = false;
          _currentMeaningOptions = List<WordModel>.from(_currentGroup)..shuffle();
        });

        return;
      }
    }

    setState(() {
      _selectedJapaneseWordId = null;
      _flashJapaneseId = null;
      _flashMeaningWordId = null;
      _flashIsCorrect = null;
      _isProcessingSelection = false;
    });
  }

  Color _japaneseTileColor(WordModel word) {
    if (_matchedIdsInCurrentGroup.contains(word.id)) {
      return const Color(0xFFDDEFE2);
    }

    if (_flashJapaneseId == word.id && _flashIsCorrect == true) {
      return const Color(0xFFCFEAD6);
    }

    if (_flashJapaneseId == word.id && _flashIsCorrect == false) {
      return const Color(0xFFF6CFCF);
    }

    if (_selectedJapaneseWordId == word.id) {
      return const Color(0xFFF2F2F2);
    }

    return Colors.white;
  }

  Color _japaneseTileBorderColor(WordModel word) {
    if (_matchedIdsInCurrentGroup.contains(word.id)) {
      return const Color(0xFF7DB08A);
    }

    if (_flashJapaneseId == word.id && _flashIsCorrect == true) {
      return const Color(0xFF5DAA72);
    }

    if (_flashJapaneseId == word.id && _flashIsCorrect == false) {
      return const Color(0xFFD96B6B);
    }

    if (_selectedJapaneseWordId == word.id) {
      return Colors.black87;
    }

    return const Color(0xFFBEBEBE);
  }

  Color _meaningTileColor(WordModel word) {
    if (_matchedIdsInCurrentGroup.contains(word.id)) {
      return const Color(0xFFDDEFE2);
    }

    if (_flashMeaningWordId == word.id && _flashIsCorrect == true) {
      return const Color(0xFFCFEAD6);
    }

    if (_flashMeaningWordId == word.id && _flashIsCorrect == false) {
      return const Color(0xFFF6CFCF);
    }

    return Colors.white;
  }

  Color _meaningTileBorderColor(WordModel word) {
    if (_matchedIdsInCurrentGroup.contains(word.id)) {
      return const Color(0xFF7DB08A);
    }

    if (_flashMeaningWordId == word.id && _flashIsCorrect == true) {
      return const Color(0xFF5DAA72);
    }

    if (_flashMeaningWordId == word.id && _flashIsCorrect == false) {
      return const Color(0xFFD96B6B);
    }

    return const Color(0xFFBEBEBE);
  }

  @override
  Widget build(BuildContext context) {
    if (_allWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('퀴즈'),
        ),
        body: const Center(
          child: Text('퀴즈를 만들 수 있는 단어가 없습니다.'),
        ),
      );
    }

    final progress = _matchedWordCount / _allWords.length;

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuizProgressBar(progress: progress),
              const SizedBox(height: 14),
              Text(
                '${_matchedWordCount} / ${_allWords.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '왼쪽 일본어와 오른쪽 뜻을 연결하세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: _currentGroup.map((word) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuizItemButton(
                              text: word.content,
                              backgroundColor: _japaneseTileColor(word),
                              borderColor: _japaneseTileBorderColor(word),
                              isDisabled:
                              _matchedIdsInCurrentGroup.contains(word.id),
                              onTap: () => _onTapJapanese(word),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: _currentMeaningOptions.map((word) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuizItemButton(
                              text: _meaningText(word),
                              backgroundColor: _meaningTileColor(word),
                              borderColor: _meaningTileBorderColor(word),
                              isDisabled:
                              _matchedIdsInCurrentGroup.contains(word.id),
                              fontSize: 14,
                              onTap: () => _onTapMeaning(word),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizProgressBar extends StatelessWidget {
  const _QuizProgressBar({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 14,
        value: progress,
        backgroundColor: const Color(0xFFFFEDED),
        valueColor: const AlwaysStoppedAnimation<Color>(
          Color(0xFFFFB3B3),
        ),
      ),
    );
  }
}

class _QuizItemButton extends StatelessWidget {
  const _QuizItemButton({
    required this.text,
    required this.backgroundColor,
    required this.borderColor,
    required this.isDisabled,
    required this.onTap,
    this.fontSize = 18,
  });

  final String text;
  final Color backgroundColor;
  final Color borderColor;
  final bool isDisabled;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.72 : 1,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isDisabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}