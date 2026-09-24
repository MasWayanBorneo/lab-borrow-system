import 'dart:io';
import '/app/services/auth_service.dart';
import 'controller.dart';

class RegisterController extends Controller {
  final AuthService authService = AuthService();

  Future<void> register({
    required String name,
    required String nim,
    required String email,
    required String password,
    File? ktmFile,
  }) async {
    await authService.signUp(
      name: name,
      nim: nim,
      email: email,
      password: password,
      ktmFile: ktmFile,
    );
  }
}
