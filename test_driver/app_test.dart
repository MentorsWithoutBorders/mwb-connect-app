import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {

  group('Testing MWB Connect App', () {
    FlutterDriver driver;
    const goToLogin = 'goToLogin';

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('check flutter driver health', () async {
      Health health = await driver.checkHealth();
      print(health.status);
    });    
    
    test('Login test', () async {
      await driver.tap(find.byValueKey(goToLogin));
      await driver.tap(find.byValueKey('email'));
      await driver.enterText('edmondpr@gmail.com');
      await driver.tap(find.byValueKey('password'));
      await driver.enterText('01716562');
      await driver.tap(find.byValueKey('primary_button'));
    });
     
  });
}