import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<bool> register() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Please fill in all fields";
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      errorMessage = "Password must be at least 6 characters long";
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      errorMessage = "Password must contain an uppercase letter and a number";
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      errorMessage = "Passwords do not match";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
