import 'package:copycat_base/domain/model/auth_user/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

extension AuthUserExtension on sb.User {
  AuthUser toAuthUser() {
    return AuthUser(
      userId: id,
      email: email!,
      displayName: userMetadata?["displayName"],
      enc2KeyId: userMetadata?["enc2KeyId"],
      enc1: userMetadata?["enc1"],
    );
  }
}
