// ============================================================
// 학습 화면 상태 관리 Provider
// DB 연결 시 이 파일만 수정하면 UI는 자동으로 반영됨
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================
// [모델] 단어 카테고리
// ============================================================
// TODO [Firestore 연결 시]: id를 Firestore 문서 ID로 교체
// TODO [DB 연결 시]: 필요한 필드 추가 (예: 총 단어 수, 학습 완료 수 등)
class WordCategory {
  final String id;      // 카테고리 고유 ID (현재 임시값: 'n5', 'n4' 등)
  final String title;   // 화면에 표시할 카테고리 이름

  const WordCategory({required this.id, required this.title});
}

// ============================================================
// [Provider] 단어 카테고리 목록
// ============================================================
// 현재: 하드코딩된 임시 데이터 반환
//
// TODO [Firestore 연결 시]: 아래 코드로 교체
//   FirebaseFirestore.instance.collection('word_categories').get()
//
// 교체 방법:
//   Provider → FutureProvider 로 변경하고
//   학습 화면에서 ref.watch(...) 결과를 AsyncValue로 처리하면 됨
final wordCategoryProvider = Provider<List<WordCategory>>((ref) {
  // TODO [Firestore 연결 시]: 이 return 블록 전체를 Firestore 호출 코드로 교체
  return const [
    WordCategory(id: 'n5', title: 'JLPT N5 필수 단어'),
    WordCategory(id: 'n4', title: 'JLPT N4 필수 단어'),
    WordCategory(id: 'n3', title: 'JLPT N3 필수 단어'),
    WordCategory(id: 'n2', title: 'JLPT N2 필수 단어'),
    WordCategory(id: 'n1', title: 'JLPT N1 필수 단어'),
  ];
});
