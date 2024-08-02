//@GeneratedMicroModule;CopycatProPackageModule;package:copycat_pro/di/di.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:copycat_base/domain/repositories/auth.dart' as _i281;
import 'package:copycat_base/domain/repositories/drive_credential.dart'
    as _i447;
import 'package:copycat_base/domain/sources/clip_collection.dart' as _i569;
import 'package:copycat_base/domain/sources/clipboard.dart' as _i191;
import 'package:copycat_base/domain/sources/subscription.dart' as _i860;
import 'package:copycat_base/domain/sources/sync_clipboard.dart' as _i903;
import 'package:copycat_pro/bloc/monetization_cubit/monetization_cubit.dart'
    as _i1051;
import 'package:copycat_pro/data/repositories/auth.dart' as _i789;
import 'package:copycat_pro/data/repositories/drive_credential.dart' as _i729;
import 'package:copycat_pro/data/repositories/subscription.dart' as _i140;
import 'package:copycat_pro/data/sources/clip_collection/remote_source.dart'
    as _i342;
import 'package:copycat_pro/data/sources/clipboard/remote_source.dart' as _i533;
import 'package:copycat_pro/data/sources/subscription/remote_source.dart'
    as _i696;
import 'package:copycat_pro/data/sources/sync_clipboard/remote_source.dart'
    as _i558;
import 'package:copycat_pro/di/modules.dart' as _i240;
import 'package:copycat_pro/domain/repositories/subscription.dart' as _i276;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

class CopycatProPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final registerModule = _$RegisterModule();
    gh.factory<String>(
      () => registerModule.supabaseUrl,
      instanceName: 'supabase_url',
    );
    gh.factory<String>(
      () => registerModule.supabaseKey,
      instanceName: 'supabase_key',
    );
    await gh.singletonAsync<_i454.SupabaseClient>(
      () => registerModule.client(
        gh<String>(instanceName: 'supabase_url'),
        gh<String>(instanceName: 'supabase_key'),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i281.AuthRepository>(
        () => _i789.AuthRepositoryImpl(client: gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i903.SyncClipboardSource>(
      () => _i558.SyncClipboardSourceImpl(gh<_i454.SupabaseClient>()),
      instanceName: 'remote',
    );
    gh.lazySingleton<_i191.ClipboardSource>(
      () => _i533.RemoteClipboardSource(gh<_i454.SupabaseClient>()),
      instanceName: 'remote',
    );
    gh.lazySingleton<_i860.SubscriptionSource>(
      () => _i696.RemoteSubscriptionSource(client: gh<_i454.SupabaseClient>()),
      instanceName: 'remote',
    );
    gh.lazySingleton<_i569.ClipCollectionSource>(
      () => _i342.RemoteClipCollectionSource(gh<_i454.SupabaseClient>()),
      instanceName: 'remote',
    );
    gh.lazySingleton<_i447.DriveCredentialRepository>(
        () => _i729.DriveCredentialRepositoryImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i276.SubscriptionRepository>(() =>
        _i140.SubscriptionRepositoryImpl(
            remote: gh<_i860.SubscriptionSource>(instanceName: 'remote')));
    gh.singleton<_i1051.MonetizationCubit>(() =>
        _i1051.MonetizationCubit(repo: gh<_i276.SubscriptionRepository>()));
  }
}

class _$RegisterModule extends _i240.RegisterModule {}
