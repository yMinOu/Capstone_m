import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPageRepository {
  MyPageRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount(User user) async {
    await _reauthenticateWithGoogle();

    final refreshedUser = _firebaseAuth.currentUser;
    if (refreshedUser == null) {
      throw Exception('사용자 정보를 다시 불러오지 못했습니다.');
    }

    // Firestore users 문서 삭제
    await _firestore.collection('users').doc(refreshedUser.uid).delete();

    // Firebase Authentication 유저 삭제
    await refreshedUser.delete();

    // 구글 세션 정리
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}

    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> _reauthenticateWithGoogle() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인한 사용자가 없습니다.');
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('재인증이 취소되었습니다.');
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await currentUser.reauthenticateWithCredential(credential);
  }
}