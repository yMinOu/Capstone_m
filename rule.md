# RULE

## 상태관리

* Riverpod 사용
* 화면 내부 일시 상태만 local state 허용
* UI와 상태 로직 분리

---

## 구조

* feature 기능 단위 분리
* screen에는 UI만 작성
* widget은 재사용 가능한 UI 단위로 분리
* screen에서 repository 직접 호출 금지
* provider를 통해 repository 접근
* Firebase / DB / API 호출은 repository에서만 처리
* core 앱 전역에서 공통으로 사용하는 유틸, 테마, 라우팅
* assets에는 /images, /fonts, /icons 정적 파일 하위 폴더로 분류

---

## DB

* repository 통해 접근
* 데이터 모델은 별도 파일로 분리

---

## import

* package import 사용
* 상대경로 import 금지 (`../`, `../../` 사용 금지)

### example

* `import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';`

---

## 네이밍

* screen: `xxx_screen.dart`
* provider: `xxx_provider.dart`
* repository: `xxx_repository.dart`
* model: `xxx_model.dart`
* widget: `xxx_widget.dart`
* notifier 분리 시: `xxx_notifier.dart`

---

## documentation

* 새로운 파일 생성 시 파일 최상단에 역할 설명 주석 작성
* 모든 소스 코드 파일은 최대한 500줄 이하 유지

---

## 커밋

* 미완성 기능 커밋 금지
* 기능 완료 후 커밋

### prefix

* feat: 새로운 기능 추가
* fix: 버그 및 오류 수정
* refactor: 구조 개선 및 코드 정리
* style: UI 수정
* docs: 문서 수정
* chore: 기타 변경사항

### example

* [feat] 단어장 생성 기능 추가
* [feat] 히라가나 퀴즈 화면 추가
* [fix] 화면 전환 오류 수정
* [refactor] auth provider 분리