import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/home/presentation/home_screen.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: Routes.home,
  routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
);
