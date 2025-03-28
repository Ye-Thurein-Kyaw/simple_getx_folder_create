import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'api_exception.dart';
import 'network_log_helper.dart';
import '/utils/app_const.dart';

enum _ReqType {
  getRequest,
  postRequest,
}

class ApiService extends GetConnect {
  static const String baseApiUrl = ' ';
  String? _token;

  set token(String token) => _token = token;

  ApiService() {
    httpClient.baseUrl = baseApiUrl;

    loadToken();

    httpClient.addRequestModifier<dynamic>((request) async {
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      final bodyBytes = await request.bodyBytes.toBytes();

      if (bodyBytes.isNotEmpty) {
        final decodedBody = utf8.decode(bodyBytes);
        log('Request Body: $decodedBody'); 
      } else {
        log('Request Body: No body');
      }

      return request;
    });

    httpClient.errorSafety = true;
    httpClient.timeout = const Duration(seconds: 10);
  }

  void loadToken() {
    _token = box.read(Spf.token);
  }

  Future<Response> getReq(
    String endPoint, {
    String? secondaryUrl,
  }) {
    return _apiReq(_ReqType.getRequest, endPoint, secondaryUrl: secondaryUrl);
  }

  Future<Response> postReq(
    String endPoint, {
    FormData? formData,
    String? secondaryUrl,
    Map<String, dynamic>? mapData,
  }) {
    return _apiReq(_ReqType.postRequest, endPoint,
        formData: formData, mapData: mapData);
  }

  Future<Response> _apiReq(
    _ReqType reqType,
    String endPoint, {
    FormData? formData,
    Map<String, dynamic>? mapData,
    String? secondaryUrl,
  }) async {
    Response response;
    try {
      if (reqType == _ReqType.getRequest) {
        response = await get(
          secondaryUrl ?? endPoint,
        );
      } else {
        response = await post(
          secondaryUrl ?? endPoint,
          formData ?? mapData,
        );
      }

      if (response.status.connectionError) {
        log('No internet');
        throw ApiException.connectionError();
      } else if (response.statusCode == 200) {
        return response;
      } else if (response.statusCode == 422) {
        throw ApiException.userError(message: response.body['message']);
      } else if (response.statusCode == 500) {
        throw ApiException.internalServerError();
      } else if (response.statusCode == 404) {
        throw ApiException.notFound();
      } else if (response.statusCode == 401) {
        throw ApiException.authError(
            message: endPoint == "/login" ? null : response.body['message']);
      } else {
        throw ApiException(
          messageEn: response.body['message'],
          messageMM: response.body['message'],
          statusCode: response.statusCode ?? -1,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      log("catch block : $e"); 
      if (e.toString().contains('Connecting timed out') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('connection error')) {
        throw ApiException.connectionError();
      } else {
        throw ApiException();
      }
    }
  }
}
