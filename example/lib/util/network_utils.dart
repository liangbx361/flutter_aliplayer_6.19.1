import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_aliplayer_example/config.dart';

class NetWorkUtils {
  static final NetWorkUtils _instance = NetWorkUtils._privateConstructor();

  static NetWorkUtils get instance {
    return _instance;
  }

  static var _dio;

  NetWorkUtils._privateConstructor() {
    if (_dio == null) {
      _dio = Dio();
      _dio.options.connectTimeout = Duration(milliseconds: 5000);
      _dio.options.receiveTimeout = Duration(milliseconds: 5000);
      _dio.options.baseUrl = HttpConstant.HTTP_HOST;
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) {
          return true;
        };
        return null;
      };
    }
  }

  void getHttp(String url,
      { Map<String, dynamic>? params,
        required Function successCallback,
        required Function errorCallback}) async {
    Response response = await _dio.get(url, queryParameters: params);
    Map<String, dynamic> data = response.data;
    if (data.isNotEmpty && data['result'] == 'true') {
      successCallback(data['data']);
    } else {
      errorCallback(data);
    }
  }

  Future<Map> getHttpFuture(String url, {required Map<String, String> params}) async {
    Response response = await _dio.get(url, queryParameters: params);
    Map<String, dynamic> data = response.data;
    if (data.isNotEmpty && data['result'] == 'true') {
      return Future.value(data['data']);
    } else {
      return Future.error("$url request error");
    }
  }
}
