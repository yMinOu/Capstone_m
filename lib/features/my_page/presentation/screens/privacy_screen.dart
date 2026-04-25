/// 개인정보 처리방침 화면.
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          '''개인정보 처리방침

Nihongo(이하 "앱")는 사용자의 개인정보를 중요하게 생각하며, 관련 법령을 준수합니다.

제1조 (수집하는 개인정보 항목)
앱은 Google 로그인 시 다음 정보를 수집합니다.
• 이름
• 이메일 주소
• 프로필 사진

제2조 (개인정보 수집 목적)
수집된 정보는 다음 목적으로만 사용됩니다.
• 회원 식별 및 서비스 제공
• 학습 기록 저장 및 통계 제공
• 공지사항 및 서비스 안내

제3조 (개인정보 보유 및 이용 기간)
개인정보는 서비스 이용 기간 동안 보유하며, 회원 탈퇴 시 즉시 삭제됩니다.

제4조 (제3자 제공)
앱은 사용자의 개인정보를 외부에 제공하지 않습니다. 단, 법령에 의한 요구가 있는 경우는 예외로 합니다.

제5조 (개인정보 보호 조치)
앱은 Firebase를 통해 데이터를 안전하게 관리하며, 불필요한 개인정보는 수집하지 않습니다.

제6조 (사용자의 권리)
사용자는 언제든지 앱 내 마이페이지에서 계정 탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.

제7조 (문의)
개인정보 관련 문의는 앱 내 의견 남기기를 통해 접수하실 수 있습니다.

시행일: 2025년 1월 1일''',
          style: TextStyle(fontSize: 14, height: 1.8),
        ),
      ),
    );
  }
}
