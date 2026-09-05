import 'package:flutter_test/flutter_test.dart';
import 'package:studylock/main.dart';

void main() {
  testWidgets('renders the StudyLock dashboard', (tester) async {
    await tester.pumpWidget(const StudyLock());

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Focus Mode'), findsOneWidget);
    expect(find.text('Preparation'), findsOneWidget);
  });
}
