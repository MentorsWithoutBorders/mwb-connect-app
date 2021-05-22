import 'package:dio/dio.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class ApiService {
  static final LocalStorageService _storageService = locator<LocalStorageService>();
  static final String baseUrl = 'http://104.131.124.125:3000/api/v1';
  static BaseOptions opts = BaseOptions(
    responseType: ResponseType.json,
    connectTimeout: 30000,
    receiveTimeout: 30000,
  );

  static Dio createDio() {
    return Dio(opts);
  }

  static Dio addInterceptors(Dio dio) {
    return dio
      ..interceptors.add(
        InterceptorsWrapper(
            onRequest: (RequestOptions options, RequestInterceptorHandler handler) => requestInterceptor(handler, options),
            onError: (DioError e, ErrorInterceptorHandler handler) async {
              return e.response.data;
            }),
      );
  }

  static dynamic requestInterceptor(RequestInterceptorHandler handler, RequestOptions options) async {
    String token = _storageService.accessToken;
    options.headers.addAll({"Authorization": "$token"});
    return handler.next(options);
  }

  static final dio = createDio();
  static final baseAPI = addInterceptors(dio);

  Future<Response> getHTTP({String url}) async {
    try {
      Response response = await baseAPI.get(baseUrl + url);
      return response;
    } on DioError catch(e) {
      // Handle error
    }
  }

  Future<Response> postHTTP({String url, dynamic data}) async {
    try {
      Response response = await baseAPI.post(baseUrl + url, data: data);
      return response;
    } on DioError catch(e) {
      print(e);
    }
  }

  Future<Response> putHTTP(String url, dynamic data) async {
    try {
      Response response = await baseAPI.put(url, data: data);
      return response;
    } on DioError catch(e) {
      // Handle error
    }
  }
  
  Future<Response> deleteHTTP(String url) async {
    try {
      Response response = await baseAPI.delete(url);
      return response;
    } on DioError catch(e) {
      // Handle error
    }
  }
}