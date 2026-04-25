/// 이용약관 화면.
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(
          '''Nihongo 서비스 이용약관

제1조 (목적)
본 약관은 Nihongo(이하 "앱")가 제공하는 일본어 학습 서비스의 이용 조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.

제2조 (서비스 내용)
앱은 일본어 단어, 문장, 한자 학습 및 학습 통계 등의 기능을 제공합니다.

제3조 (이용 조건)
본 서비스는 Google 계정을 통한 로그인 후 이용 가능합니다. 만 14세 미만의 경우 보호자의 동의가 필요합니다.

제4조 (사용자 의무)
사용자는 타인의 계정을 무단으로 사용하거나, 서비스의 정상적인 운영을 방해하는 행위를 해서는 안 됩니다.

제5조 (금지 사항)
서비스 내 콘텐츠를 무단으로 복제, 배포, 상업적으로 이용하는 행위를 금지합니다.

제6조 (서비스 변경 및 중단)
앱은 서비스 내용을 변경하거나 중단할 수 있으며, 이로 인한 손해에 대해 별도의 보상을 하지 않습니다.

제7조 (면책 조항)
앱은 사용자의 귀책 사유로 발생한 손해 및 천재지변 등 불가항력으로 인한 서비스 장애에 대해 책임을 지지 않습니다.

제8조 (약관 변경)
약관이 변경될 경우 앱 공지사항을 통해 사전 고지합니다.

시행일: 2025년 1월 1일''',
          style: TextStyle(fontSize: 14, height: 1.8),
        ),
      ),
    );
  }
}
