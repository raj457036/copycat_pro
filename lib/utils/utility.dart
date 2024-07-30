import 'package:universal_io/io.dart';

bool get iapCatSupportedPlatform =>
    Platform.isIOS || Platform.isMacOS || Platform.isAndroid;
