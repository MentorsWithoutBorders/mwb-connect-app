import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/log_entry_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class LoggerService {
  final ApiService _api = locator<ApiService>();

  Future<void> addLogEntry(String text) async {
    LogEntry logEntry = LogEntry(text: text);
    await _api.postHTTP(url: '/logger', data: logEntry.toJson());
  }
}