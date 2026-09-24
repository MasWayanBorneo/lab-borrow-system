class Item {
  String? id;
  String? name;
  String? code;
  String? category;
  int? totalQty;
  int? availableQty;
  String? imageUrl;
  bool isReady = true;

  Item();

  Item.fromJson(dynamic data) {
    id = data['id'];
    name = data['name'];
    code = data['code'];
    category = data['category'];
    totalQty = data['total_qty'];
    availableQty = data['available_qty'];
    imageUrl = data['image_url'];
    isReady = data['is_ready'] ?? true;
  }

  bool get isAvailable => isReady && (availableQty ?? 0) > 0;

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "category": category,
        "total_qty": totalQty,
        "available_qty": availableQty,
        "image_url": imageUrl,
        "is_ready": isReady,
      };
}
