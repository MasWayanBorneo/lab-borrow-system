import '/app/controllers/login_controller.dart';
import '/app/controllers/register_controller.dart';
import '/app/controllers/item_list_controller.dart';
import '/app/controllers/item_detail_controller.dart';
import '/app/controllers/my_loans_controller.dart';
import '/app/controllers/admin_approval_controller.dart';
import '/app/controllers/admin_returns_controller.dart';
import '/app/controllers/admin_items_controller.dart';
import '/app/models/user.dart';
import '/app/models/item.dart';
import '/app/models/loan.dart';
import '/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/7.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  //
  User: (data) => User.fromJson(data),

  List<Item>: (data) =>
      List.from(data).map((json) => Item.fromJson(json)).toList(),
  Item: (data) => Item.fromJson(data),

  List<Loan>: (data) =>
      List.from(data).map((json) => Loan.fromJson(json)).toList(),
  Loan: (data) => Loan.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/7.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // ...
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/7.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  LoginController: () => LoginController(),
  RegisterController: () => RegisterController(),
  ItemListController: () => ItemListController(),
  ItemDetailController: () => ItemDetailController(),
  MyLoansController: () => MyLoansController(),
  AdminApprovalController: () => AdminApprovalController(),
  AdminReturnsController: () => AdminReturnsController(),
  AdminItemsController: () => AdminItemsController(),

  // ...
};
