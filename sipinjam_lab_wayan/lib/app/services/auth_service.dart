import 'dart:io';
import '/app/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signUp({
    required String name,
    required String nim,
    required String email,
    required String password,
    File? ktmFile,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {"name": name, "nim": nim},
    );

    if (ktmFile != null && res.user != null) {
      await uploadKtm(res.user!.id, ktmFile);
    }
  }

  /// Uploads a KTM/KTP photo to the private `identity-proofs` bucket under
  /// the user's own folder, then saves the storage path on their profile.
  Future<void> uploadKtm(String userId, File file) async {
    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

    await _client.storage.from('identity-proofs').upload(fileName, file);

    await _client
        .from('profiles')
        .update({"ktm_path": fileName}).eq('id', userId);
  }

  /// Creates a short-lived signed URL to view a private KTM/KTP photo.
  Future<String> signedKtmUrl(String path, {int expiresIn = 3600}) {
    return _client.storage
        .from('identity-proofs')
        .createSignedUrl(path, expiresIn);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetches the `profiles` row for the current session and merges it with
  /// the auth user's email into a [User] model.
  Future<User?> currentProfile() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final data =
        await _client.from('profiles').select().eq('id', authUser.id).single();

    return User.fromJson({...data, "email": authUser.email});
  }
}
