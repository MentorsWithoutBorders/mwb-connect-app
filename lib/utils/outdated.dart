import 'dart:convert';
import "dart:io";

import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import "package:yaml/yaml.dart";

main() async {
  File file = File('./pubspec.yaml');
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  YamlMap dependencies = yaml['dependencies'];
//  print(dependencies);

  for (var key in dependencies.keys) {
    var version = dependencies[key];
    if (version is String) {
      var versionNumber = version.replaceFirst('^', '');
      print(key + ': ' + versionNumber);

      Response html = await http.get(Uri.https('pub.dev', 'packages/'+key));

      Document document = parser.parse(html.body);

      Element? jsonScript =
          document.querySelector('script[type="application/ld+json"]');
      if (jsonScript != null) {
        var json = jsonDecode(jsonScript.innerHtml);
  //      print(json['version']);
        if (json['version'].toString().compareTo(versionNumber) > 0) {
          print(' => ' + json['version']);
        }
      }
    }
  }
}