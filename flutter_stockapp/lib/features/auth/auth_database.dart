import 'auth_database_base.dart';
import 'auth_database_stub.dart'
    if (dart.library.io) 'auth_database_io.dart'
    as implementation;

export 'auth_database_base.dart';

AuthDatabase createAuthDatabase() {
  return implementation.createAuthDatabase();
}
