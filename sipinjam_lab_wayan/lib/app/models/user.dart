import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? id;
  String? name;
  String? email;
  String? nim;
  String? role;
  String? ktmPath;

  static final StorageKey key = 'user';

  User() : super(key: key);

  bool get isAdmin => role == 'admin';

  User.fromJson(dynamic data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    nim = data['nim'];
    role = data['role'];
    ktmPath = data['ktm_path'];
  }

  @override
  toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "nim": nim,
        "role": role,
        "ktm_path": ktmPath,
      };
}
