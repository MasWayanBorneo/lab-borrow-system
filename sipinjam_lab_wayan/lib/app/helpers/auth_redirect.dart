import '/resources/pages/item_list_page.dart';
import '/resources/pages/admin_approval_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Routes to the correct home page based on the logged-in user's role.
/// Used both right after login/register and on app boot when a session
/// already exists, so a user doesn't have to log in every time they open
/// the app.
void routeToHomeForRole() {
  String? role = Auth.data(field: 'role');

  if (role == 'admin') {
    routeTo(AdminApprovalPage.path,
        navigationType: NavigationType.pushAndForgetAll);
    return;
  }

  routeTo(ItemListPage.path, navigationType: NavigationType.pushAndForgetAll);
}
