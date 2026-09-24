import '/resources/pages/item_list_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Admin Route Guard
|--------------------------------------------------------------------------
| Only allows access to users whose `profiles.role` is 'admin'.
| Assumes AuthRouteGuard already ran and confirmed the user is logged in.
|-------------------------------------------------------------------------- */

class AdminRouteGuard extends NyRouteGuard {
  AdminRouteGuard();

  @override
  Future<GuardResult> onBefore(RouteContext context) async {
    String? role = Auth.data(field: 'role');
    if (role != 'admin') {
      return redirect(ItemListPage.path);
    }

    return next();
  }
}
