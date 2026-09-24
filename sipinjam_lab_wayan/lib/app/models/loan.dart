import '/app/models/item.dart';

class Loan {
  String? id;
  String? userId;
  String? itemId;
  int? qty;
  DateTime? borrowDate;
  DateTime? returnDatePlanned;
  DateTime? returnDateActual;
  String? status;

  /// Populated when the query joins `items(*)`.
  Item? item;

  /// Populated when the query joins `profiles(*)` (name, nim) - admin views.
  String? borrowerName;
  String? borrowerNim;
  String? borrowerKtmPath;

  Loan();

  Loan.fromJson(dynamic data) {
    id = data['id'];
    userId = data['user_id'];
    itemId = data['item_id'];
    qty = data['qty'];
    borrowDate = _parseDate(data['borrow_date']);
    returnDatePlanned = _parseDate(data['return_date_planned']);
    returnDateActual = _parseDate(data['return_date_actual']);
    status = data['status'];

    if (data['items'] != null) {
      item = Item.fromJson(data['items']);
    }
    if (data['profiles'] != null) {
      borrowerName = data['profiles']['name'];
      borrowerNim = data['profiles']['nim'];
      borrowerKtmPath = data['profiles']['ktm_path'];
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  bool get isLate =>
      status == 'approved' &&
      returnDatePlanned != null &&
      DateTime.now().isAfter(returnDatePlanned!);

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "item_id": itemId,
        "qty": qty,
        "borrow_date": borrowDate?.toIso8601String(),
        "return_date_planned": returnDatePlanned?.toIso8601String(),
        "return_date_actual": returnDateActual?.toIso8601String(),
        "status": status,
      };
}
