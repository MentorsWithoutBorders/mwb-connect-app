import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mwb_connect_app/main.dart' as app;
import 'package:mwb_connect_app/utils/keys.dart';
import '../test/ui/views/profile/widgets/field_dropdown_widget_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Profile test", (WidgetTester tester) async {
    
    final Finder loginEmailField = find.byKey(Key(AppKeys.loginEmailField));
    final Finder loginPasswordField = find.byKey(Key(AppKeys.loginPasswordField));
    final Finder loginSignupPrimaryBtn = find.byKey(Key(AppKeys.loginSignupPrimaryBtn));
    final scaffoldKey = GlobalKey<ScaffoldState>();

    app.main();
    await tester.pumpAndSettle(Duration(seconds: 1));
    // await tester.tap(find.byKey(Key(AppKeys.goToLoginBtn)));
    // await tester.pumpAndSettle();
    // await tester.tap(loginEmailField);
    // await tester.pumpAndSettle();
    // await tester.enterText(loginEmailField, 'edmondpr@gmail.com');
    // await tester.tap(loginPasswordField);
    // await tester.pumpAndSettle();
    // await tester.enterText(loginPasswordField, '01716562');
    // await tester.tap(loginSignupPrimaryBtn);
    //scaffoldKey.currentState.openDrawer();
    await tester.dragFrom(tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await tester.tap(find.text('My profile'));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await FieldDropdownWidgetTest.changeFieldTest(tester);
    await tester.pumpAndSettle(Duration(seconds: 1));
  });
}