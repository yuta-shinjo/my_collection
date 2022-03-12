import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_collection/models/src/album.dart';
import 'package:my_collection/models/src/user.dart';

import 'src/field_name.dart';

class FireUsersService {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = firebase.FirebaseAuth.instance;

  Future<void> emailLogin(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<firebase.UserCredential> googleLogin() async {
    final googleUser = await GoogleSignIn(scopes: [
      'email',
    ]).signIn();
    // リクエストから、認証情報を取得
    final googleAuth = await googleUser?.authentication;
    // クレデンシャルを新しく作成
    final credential = firebase.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // サインインしたら、UserCredentialを返す
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> registerUser(String newEmail, String newPassword) async {
    await _auth
        .createUserWithEmailAndPassword(
      email: newEmail,
      password: newPassword,
    )
        .then((currentUser) {
      _fireStore.collection("users").doc(currentUser.user?.uid).set({});
    });
  }

// メールアドレスを連携
  Future<void> linkEmail(String email, String password) async {
    final credential =
        firebase.EmailAuthProvider.credential(email: email, password: password);
    await _auth.currentUser!.linkWithCredential(credential);
  }

  // 匿名でログイン
  Future<void> anonymouslyRegisterUser() async {
    await _auth.signInAnonymously();
  }

  Future<void> registerUserProfile(
    String name,
    String profileImageUrl,
  ) async {
    await _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('profile')
        .doc(_auth.currentUser?.uid)
        .set({
      FieldName.name: name,
      FieldName.imgUrls: profileImageUrl,
    });
  }

  Future<void> registerGoogleUserProfile(
    String? name,
    String? imgUrl,
  ) async {
    await _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('profile')
        .doc(_auth.currentUser?.uid)
        .set({
      FieldName.name: _auth.currentUser?.displayName,
      FieldName.imgUrls: _auth.currentUser?.photoURL,
    });
  }

  Future<User?> fetchUserProfile() async {
    final snapshot = await _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('profile')
        .doc(_auth.currentUser?.uid)
        .get();
    final data = snapshot.data();
    final user = data != null ? User.fromJson(data) : null;
    return user;
  }

  Future<void> updateProfile(
      File? imageFile, String imgUrls, String name) async {
    if (imageFile == null && imgUrls == '') {
      imgUrls == '';
    }
    if (imageFile == null && imgUrls != '') {
      imgUrls;
    }

    await _fireStore
        .collection("users")
        .doc(_auth.currentUser?.uid)
        .collection('profile')
        .doc(_auth.currentUser?.uid)
        .update({
      FieldName.name: name,
      FieldName.imgUrls: imgUrls,
    });
  }

  Future fetchAlbumList({required Function(List<Album>) onValueChanged}) async {
    final usersPublicStadiumsCollectionRef = _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('albums');
    final snapShot = await usersPublicStadiumsCollectionRef.get();
    final List<Album>? albums =
        snapShot.docs.map((e) => Album.fromJson(e.data())).toList();
    if (albums == null) {
      return;
    }
    return onValueChanged(albums);
  }

  // firebaseとstorageに同じidで保存できるようにするために
  // 予めidを作成しておく
  Future<String> createId() async {
    final collectionRef = _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('albums');
    final id = collectionRef.doc().id;
    return id;
  }

  Future<List<String>> createAlbum(
    String content,
    String imgUrls,
    String id,
    String? tookDay,
    String? latitudeRef,
    String? latitude,
    String? longitudeRef,
    String? longitude,
    List<String> tags,
    bool public,
  ) async {
    final collectionRef = _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('albums');
    await collectionRef.doc(id).set({
      FieldName.content: content,
      FieldName.created: FieldValue.serverTimestamp(),
      FieldName.id: id,
      FieldName.imgUrls: imgUrls,
      FieldName.public: public,
      FieldName.latitude: latitude ?? '',
      FieldName.latitudeRef: latitudeRef ?? '',
      FieldName.longitude: longitude ?? '',
      FieldName.longitudeRef: longitudeRef ?? '',
      FieldName.tags: tags.map((e) => e).toList(),
      FieldName.tookDay: tookDay ?? '',
    });
    return tags;
  }

  Future<void> deleteMyAlbum(Album album) {
    return _fireStore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('albums')
        .doc(album.id)
        .delete();
  }
  Future<void> deletePublicAlbum(Album album) {
    return _fireStore
        .collection('public')
        .doc('v1')
        .collection('albums')
        .doc(album.id)
        .delete();
  }
}
