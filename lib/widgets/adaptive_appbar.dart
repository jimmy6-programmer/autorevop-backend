import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget? buildAdaptiveAppBar(BuildContext context, String title,
    {List<Widget>? actions}) {
  if (Platform.isIOS) {
    return CupertinoNavigationBar(
      middle: Text(title),
      trailing: actions != null && actions.isNotEmpty ? actions.first : null,
    );
  } else {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }
}
