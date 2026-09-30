import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/extensions/context_ext.dart';
import '../../../core/widgets/state_views.dart';

/// Placeholder until the `movies` feature lands (plan.md, week 1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.homeTitle)),
    body: EmptyView(
      icon: Symbols.movie_rounded,
      message: context.l10n.homeComingSoon,
    ),
  );
}
