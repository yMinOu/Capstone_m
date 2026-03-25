/// FirebaseAuth + GoogleSignIn을 이용한 인증 로직 처리.
/// 로그인, 로그아웃, 사용자 Firestore 동기화를 담당한다.
///
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<User?> signInWithGoogle() async {
    // 탈퇴/재인증 이후 꼬인 세션 방지
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
    await _firebaseAuth.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('로그인한 사용자 정보를 가져오지 못했습니다.');
    }

    await _ensureUserDocument(user);

    return user;
  }

  Future<void> _ensureUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'totalStudySeconds': 0,
        'totalStudyCount': 0,
      });
      return;
    }

    await userRef.update({
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'totalStudySeconds': snapshot.data()?['totalStudySeconds'] ?? 0,
      'totalStudyCount': snapshot.data()?['totalStudyCount'] ?? 0,
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}