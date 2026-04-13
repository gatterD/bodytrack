// lib/interface/widgets/BTAppBar.dart
import 'package:flutter/material.dart';

class BTAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? customTitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;

  const BTAppBar({
    super.key,
    this.title,
    this.customTitle,
    this.actions,
    this.showBackButton = false,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: customTitle ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Назад',
            )
          : null,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      titleSpacing: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
