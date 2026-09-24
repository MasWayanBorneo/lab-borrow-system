import 'package:nylo_framework/nylo_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider implements NyProvider {
  @override
  setup(Nylo nylo) async {
    return nylo;
  }

  @override
  boot(Nylo nylo) async {
    await Supabase.initialize(
      url: getEnv('SUPABASE_URL'),
      publishableKey: getEnv('SUPABASE_ANON_KEY'),
    );
  }
}
