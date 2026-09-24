import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LogoutEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    await AuthService().signOut();
    await Auth.logout();

    routeToInitial();
  }
}
