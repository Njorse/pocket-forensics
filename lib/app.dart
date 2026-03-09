import 'package:flutter/material.dart';

import 'shared/core/theme/app_theme.dart';
import 'features/scanner/presentation/views/scanner_view.dart';

/// Root widget for PocketForensics.
class PocketForensicsApp extends StatelessWidget {
  const PocketForensicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketForensics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ScannerView(),
    );
  }
}
