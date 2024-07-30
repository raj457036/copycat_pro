import "package:flutter/foundation.dart";
import "package:injectable/injectable.dart";
import "package:supabase_flutter/supabase_flutter.dart";

@module
abstract class RegisterModule {
  @Named("supabase_url")
  String get supabaseUrl => const String.fromEnvironment("SUPABASE_URL");

  @Named("supabase_key")
  String get supabaseKey => const String.fromEnvironment("SUPABASE_KEY");

  @preResolve
  @singleton
  Future<SupabaseClient> client(@Named("supabase_url") String url,
      @Named("supabase_key") String key) async {
    await Supabase.initialize(
      url: url,
      anonKey: key,
      debug: kDebugMode,
    );
    return Supabase.instance.client;
  }
}
