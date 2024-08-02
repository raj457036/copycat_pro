import "package:injectable/injectable.dart";

@InjectableInit.microPackage(
  throwOnMissingDependencies: true,
  externalPackageModulesBefore: [
    // ExternalModule(CopycatBasePackageModule),
  ],
)
Future<void> initModules() async {}
