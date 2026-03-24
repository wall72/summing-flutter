import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_persistence.dart';

/// Loads once; use in UI via `ref.watch(localPersistenceProvider)`.
final localPersistenceProvider = FutureProvider<LocalPersistence>((ref) async {
  return LocalPersistence.open();
});
