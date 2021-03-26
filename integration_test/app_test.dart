import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mwb_connect_app/main.dart' as app;
import '../test/ui/views/profile/widgets/name_widget_test.dart';
import '../test/ui/views/profile/widgets/field_dropdown_widget_test.dart';
import '../test/ui/views/profile/widgets/subfields_widget_test.dart';
import '../test/ui/views/profile/widgets/availability_list_widget_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets("App test", (WidgetTester tester) async {
    app.main(); 
    await tester.pumpAndSettle(Duration(seconds: 2));
    
    // Login test
    // final Finder loginEmailField = find.byKey(Key(AppKeys.loginEmailField));
    // final Finder loginPasswordField = find.byKey(Key(AppKeys.loginPasswordField));
    // final Finder loginSignupPrimaryBtn = find.byKey(Key(AppKeys.loginSignupPrimaryBtn));

    // await tester.tap(find.byKey(Key(AppKeys.goToLoginBtn)));
    // await tester.pumpAndSettle();
    // await tester.tap(loginEmailField);
    // await tester.pumpAndSettle();
    // await tester.enterText(loginEmailField, 'mentor1@test.fake');
    // await tester.tap(loginPasswordField);
    // await tester.pumpAndSettle();
    // await tester.enterText(loginPasswordField, '123456');
    // await tester.tap(loginSignupPrimaryBtn);
    // await tester.pumpAndSettle(Duration(seconds: 1));    
    
    // Profile test
    await tester.dragFrom(tester.getTopLeft(find.byType(MaterialApp)), Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My profile'));
    await tester.pumpAndSettle();
    // Name test
    await NameWidgetTest.nameShowsUpTest();
    await NameWidgetTest.initialNameTest(tester);
    await NameWidgetTest.nameChangeTest(tester);
    // Field test
    await FieldDropdownWidgetTest.fieldShowsUpTest();
    await FieldDropdownWidgetTest.initialFieldTest(tester);
    await FieldDropdownWidgetTest.changeFieldTest(tester);
    // Subfields test
    await SubfieldsWidgetTest.subfieldsWidgetShowsUpTest();
    await SubfieldsWidgetTest.addSubfieldTest(tester);
    await SubfieldsWidgetTest.changeSubfieldTest(tester);
    await SubfieldsWidgetTest.deleteSubfieldTest(tester);
    // Availability test
    await AvailabilityListWidgetTest.widgetShowsUpTest();
    await AvailabilityListWidgetTest.addItemsTest(tester);
    await AvailabilityListWidgetTest.addItemWithMergeTest(tester);
    await AvailabilityListWidgetTest.editItemTest(tester);
    await AvailabilityListWidgetTest.editItemWithMergeTest(tester);
    await AvailabilityListWidgetTest.deleteItemTest(tester);
    await tester.pumpAndSettle(Duration(seconds: 1));    
  });  
}