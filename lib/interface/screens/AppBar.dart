import 'package:flutter/material.dart';

class BTAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;

  const BTAppBar(
      {super.key, this.title, this.actions, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : Text("No title name"),
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
