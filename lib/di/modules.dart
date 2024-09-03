import "package:flutter/foundation.dart";
import "package:injectable/injectable.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:universal_io/io.dart";

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
    final packageInfo = await PackageInfo.fromPlatform();
    final userAgent =
        "CopyCat/${packageInfo.version}+${packageInfo.buildNumber} (${Platform.operatingSystem}; ${Platform.operatingSystemVersion}; ${Platform.localeName}; Installer: ${packageInfo.installerStore ?? 'Unknown Store'})";
    await Supabase.initialize(
      url: url,
      anonKey: key,
      debug: kDebugMode,
      headers: {
        "user-agent": userAgent,
      },
    );
    return Supabase.instance.client;
  }
}
