import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error/errors.dart';

void main() {
  runApp(const ProviderScope(retry: noAutoRetry, child: App()));
}
