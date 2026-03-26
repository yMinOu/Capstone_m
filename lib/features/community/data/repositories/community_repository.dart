import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/data/models/comment_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('posts').add({
      'authorId': user.uid,
      'authorName': user.displayName ?? '익명',
      'title': title,
      'content': content,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
      'commentCount': 0,
    });
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    
    if (!doc.exists) return;
    
    final likes = List<String>.from(doc.data()?['likes'] ?? []);
    if (likes.contains(user.uid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    }
  }

  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc = await _firestore.collection('posts').doc(postId).get();
    if (!doc.exists) throw Exception('Post not found');
    
    if (doc.data()?['authorId'] != user.uid) {
      throw Exception('You do not have permission to delete this post');
    }

    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> reportPost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 실제 서비스에서는 'reports' 컬렉션에 저장하거나 관리자에게 알림을 보낼 수 있습니다.
    // 현재는 간단히 로그를 남기거나 나중에 확장 가능하도록 구조만 잡습니다.
    await _firestore.collection('reports').add({
      'postId': postId,
      'reporterId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> reportComment(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('reports').add({
      'postId': postId,
      'commentId': commentId,
      'reporterId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // 댓글 관련 메서드
  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc();

    await _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, {
        'authorId': user.uid,
        'authorName': user.displayName ?? '익명',
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final postRef = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    await _firestore.runTransaction((transaction) async {
      transaction.delete(commentRef);
      transaction.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });
    });
  }
}
