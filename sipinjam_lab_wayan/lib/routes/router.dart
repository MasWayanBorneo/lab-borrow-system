import '/resources/pages/not_found_page.dart';
import '/resources/pages/login_page.dart';
import '/resources/pages/register_page.dart';
import '/resources/pages/item_list_page.dart';
import '/resources/pages/item_detail_page.dart';
import '/resources/pages/my_loans_page.dart';
import '/resources/pages/admin_approval_page.dart';
import '/resources/pages/admin_returns_page.dart';
import '/resources/pages/admin_items_page.dart';
import '/routes/guards/auth_route_guard.dart';
import '/routes/guards/admin_route_guard.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Terminal: "metro make:page profile_page"

| Learn more https://nylo.dev/docs/7.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(LoginPage.path).initialRoute();
      router.add(RegisterPage.path);

      router.add(ItemListPage.path).addRouteGuards([AuthRouteGuard()]);
      router.add(ItemDetailPage.path).addRouteGuards([AuthRouteGuard()]);
      router.add(MyLoansPage.path).addRouteGuards([AuthRouteGuard()]);

      router
          .add(AdminApprovalPage.path)
          .addRouteGuards([AuthRouteGuard(), AdminRouteGuard()]);
      router
          .add(AdminReturnsPage.path)
          .addRouteGuards([AuthRouteGuard(), AdminRouteGuard()]);
      router
          .add(AdminItemsPage.path)
          .addRouteGuards([AuthRouteGuard(), AdminRouteGuard()]);

      router.add(NotFoundPage.path).unknownRoute();
});
