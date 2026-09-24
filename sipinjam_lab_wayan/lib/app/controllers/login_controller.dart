import '/app/services/auth_service.dart';
import '/app/events/authenticated_event.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'controller.dart';

class LoginController extends Controller {
  final AuthService authService = AuthService();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await authService.signIn(email: email, password: password);

    final user = await authService.currentProfile();
    if (user == null) {
      throw Exception("Profil pengguna tidak ditemukan");
    }

    await Auth.authenticate(data: user);
    await event<AuthenticatedEvent>();
  }
}
