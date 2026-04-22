/// FirebaseAuth + GoogleSignIn을 이용한 인증 로직 처리.
/// 로그인, 로그아웃, 사용자 Firestore 동기화를 담당한다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
              const String.fromEnvironment('ENV', defaultValue: 'dev') == 'prod'
                  ? '69037549587-sjguc0da118i6js3qpgrvbfujlr44ku8.apps.googleusercontent.com'
                  : '113939685128-lnjcg4abdauhmr0kr3kefahvfq5fi0fj.apps.googleusercontent.com',
            ),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<User?> signInWithGoogle() async {
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
    final data = snapshot.data() ?? {};

    await userRef.set({
      'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'totalStudySeconds': data['totalStudySeconds'] ?? 0,
      'totalStudyCount': data['totalStudyCount'] ?? 0,
      'streakDays': data['streakDays'] ?? 0,
      'lastStudyDateKey': data['lastStudyDateKey'],
      'updatedAt': FieldValue.serverTimestamp(),
      'isAdmin': data['isAdmin'] ?? false,
      'weakStats': data['weakStats'] ?? {
        '단어': {'know': 0, 'dontKnow': 0, 'score': 30},
        '한자': {'know': 0, 'dontKnow': 0, 'score': 30},
        '예문': {'know': 0, 'dontKnow': 0, 'score': 30},
        '가타카나': {'know': 0, 'dontKnow': 0, 'score': 30},
        '히라가나': {'know': 0, 'dontKnow': 0, 'score': 30},
        '스피킹': {'know': 0, 'dontKnow': 0, 'score': 30},
      },
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}