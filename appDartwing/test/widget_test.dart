// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dart_wing_mobile/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _TestAssetLoader extends AssetLoader {
  const _TestAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) async {
    return const <String, dynamic>{};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders login screen with login button', (WidgetTester tester) async {
    // Build our app within EasyLocalization and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('de')],
        path: 'lib/dart_wing/localization',
        fallbackLocale: const Locale('en'),
        useFallbackTranslations: true,
        saveLocale: false,
        assetLoader: const _TestAssetLoader(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the login button is rendered.
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
