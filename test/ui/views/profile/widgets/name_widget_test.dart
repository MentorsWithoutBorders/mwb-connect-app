import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import '../../../utils/test_app.dart';
import '../../../utils/widget_loader.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();

  group('Name widget tests:', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    Widget createNameWidget() {
      var widgetLoader = WidgetLoader();
      return widgetLoader.createLocalizedWidgetForTesting(
        child: TestApp(
          widget: Scaffold(
            body: Name()
          )
        ),
        jsonFile: jsonFile
      );
    }   

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob'
      );
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });   

    testWidgets('Testing name widget shows up', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pumpAndSettle();
        expect(find.text('Name'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    testWidgets('Testing initial name', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pumpAndSettle();
        expect((tester.widget(find.byKey(Key('name')).last) as TextFormField).controller.text, equals('Bob'));
      });
    });    

    testWidgets('Testing name change', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), 'Alice');
        await tester.pumpAndSettle();
        expect((tester.widget(find.byKey(Key('name')).last) as TextFormField).controller.text, equals('Alice'));
      });
    });     
  });
}