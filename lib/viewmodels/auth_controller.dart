import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';
import '../core/routes/app_routes.dart';
import '../data/providers/firebase_auth_provider.dart';
import '../data/providers/firebase_messaging_provider.dart';
import '../data/providers/firestore_provider.dart';
import '../data/providers/local_storage_provider.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isSignUpMode = false.obs;

  late final LocalStorageProvider _storage;
  late final FirebaseAuthProvider _authProvider;
  late final FirestoreProvider _firestoreProvider;
  late final FirebaseMessagingProvider _messagingProvider;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<LocalStorageProvider>();
    _authProvider = Get.find<FirebaseAuthProvider>();
    _firestoreProvider = Get.find<FirestoreProvider>();
    _messagingProvider = Get.find<FirebaseMessagingProvider>();
    isLoggedIn.value = _authProvider.currentUser != null ||
        (_storage.getBool(AppConstants.prefLoggedIn) ?? false);
  }

  String? validateEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Email is required';
    final RegExp pattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleAuthMode() {
    isSignUpMode.value = !isSignUpMode.value;
  }

  Future<void> forgotPassword() async {
    final String email = emailController.text.trim();
    final String? emailError = validateEmail(email);
    if (emailError != null) {
      Get.snackbar('Reset password', 'Enter a valid email first.');
      return;
    }

    try {
      await _authProvider.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Reset email sent',
        'Check your inbox for password reset instructions.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Reset failed', _friendlyError(e));
    } catch (e) {
      debugPrint('[Auth] forgotPassword error: $e');
      Get.snackbar('Reset failed', e.toString());
    }
  }

  Future<void> loginOrSignup() async {
    if (!formKey.currentState!.validate()) {
      await HapticFeedback.heavyImpact();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;
    await HapticFeedback.mediumImpact();

    try {
      final String email = emailController.text.trim();
      final String password = passwordController.text;

      if (isSignUpMode.value) {
        await _authProvider.signUp(email: email, password: password);
      } else {
        await _authProvider.signIn(email: email, password: password);
      }

      isLoggedIn.value = true;
      await _storage.setBool(AppConstants.prefLoggedIn, true);

      // Save / update user profile in Firestore so others can find & call us.
      final String uid = _authProvider.currentUser?.uid ?? '';
      final String fcmToken = _messagingProvider.fcmToken.value;
      if (uid.isNotEmpty) {
        await _firestoreProvider.saveUserProfile(
          uid: uid,
          email: email,
          fcmToken: fcmToken,
        );
      }

      Get.snackbar(
        'Welcome',
        isSignUpMode.value
            ? 'Account created successfully'
            : 'Signed in successfully',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] FirebaseAuthException: code=${e.code} msg=${e.message}');
      Get.snackbar('Authentication failed', _friendlyError(e));
    } catch (e) {
      debugPrint('[Auth] Unexpected error: $e');
      Get.snackbar('Authentication failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final String uid = _authProvider.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      await _firestoreProvider.setOnlineStatus(uid, isOnline: false);
    }
    await _authProvider.signOut();
    isLoggedIn.value = false;
    await _storage.setBool(AppConstants.prefLoggedIn, false);
    Get.offAllNamed(AppRoutes.login);
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      // Firebase SDK v10+ consolidates wrong-password + user-not-found into this
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'network-request-failed':
        return 'Network error. Check internet connection.';
      case 'configuration-not-found':
        return 'Firebase Authentication is not enabled. Go to Firebase Console → Authentication → Get Started, then enable Email/Password under Sign-in methods.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled. Enable it in the Firebase Console under Authentication → Sign-in methods.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'requires-recent-login':
        return 'Please log out and log in again.';
      default:
        return '[${e.code}] ${e.message ?? 'Unknown authentication error.'}';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
