import '/app/helpers/auth_redirect.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AuthenticatedEvent implements NyEvent {
  @override
  final listeners = {DefaultListener: DefaultListener()};
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic data) async {
    routeToHomeForRole();
  }
}
