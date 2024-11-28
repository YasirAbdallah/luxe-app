// نموذج المستخدم
// ignore_for_file: empty_catches

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  final String? photoURL;
  final String? username;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    this.photoURL,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isAdmin': isAdmin,
      'photoURL': photoURL,
      'username': username,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      isAdmin: map['isAdmin'],
      photoURL: map['photoURL'],
      username: map['username'],
    );
  }
}



// خدمة المصادقة


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        bool isAdmin = await _checkAdmin(userCredential.user!.email!);

        // جلب الاسم من حساب Google
        String? username = googleUser.displayName;

        final user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          isAdmin: isAdmin,
          photoURL: userCredential.user!.photoURL,
          username: username,
        );

        // حفظ بيانات المستخدم في قاعدة البيانات
        await _db.collection('users').doc(user.uid).set(user.toMap());

        // حفظ بيانات المستخدم في SharedPreferences
        await saveUserToPreferences(user);

        return user;
      }
    } catch (e) {
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    // إزالة بيانات المستخدم من SharedPreferences عند تسجيل الخروج
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> _checkAdmin(String email) async {
    DocumentSnapshot snapshot = await _db.collection('admins').doc(email).get();
    return snapshot.exists;
  }

Future<void> saveUserToPreferences(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    await prefs.setString('email', user.email);
    await prefs.setBool('isAdmin', user.isAdmin);
    await prefs.setBool('isLoggedIn', true); // حفظ حالة تسجيل الدخول
    if (user.photoURL != null) {
      await prefs.setString('photoURL', user.photoURL!);
    }
    if (user.username != null) {
      await prefs.setString('username', user.username!);
    }
  }

}

