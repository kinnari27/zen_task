import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zen_task/main.dart';
import 'package:zen_task/services/audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  
  // Initialize global audioHandler for testing
  audioHandler = MyAudioHandler();

  testWidgets('ZenTask smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ZenTaskApp());

    // Wait for SharedPreferences async load to complete and update UI state
    await tester.pumpAndSettle();

    // Verify that the main sections are loaded
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Focus List'), findsOneWidget);
  });
}
