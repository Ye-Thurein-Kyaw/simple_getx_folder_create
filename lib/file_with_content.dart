class FileWithContentClass {
  static get decodedBody => null;
  static get _token => null;
  static get e => null;

  static final filesWithContent = {
    'lib/network/api_service.dart': '''
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
        request.headers['Authorization'] = 'Bearer null'; // _token;
      }
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';

      final bodyBytes = await request.bodyBytes.toBytes();

      if (bodyBytes.isNotEmpty) {
        final decodedBody = utf8.decode(bodyBytes);
        log('Request Body: null'); // decodedBody);
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
      log("catch block : null"); // e
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

''',
    'lib/network/api_exception.dart': '''
import 'dart:convert';
import 'package:get/get.dart';

class ApiException implements Exception {
  String? messageEn;
  String? messageMM;
  int? statusCode;
  ErrType? errType;

  ApiException({
    this.messageEn = "Unknown Error Occured!",
    this.messageMM = "ပြဿနာအချို့ဖြစ်ပေါ်သွားပါသည်",
    this.statusCode = 520,
    this.errType = ErrType.unknownErr,
  });

  ApiException.notFound()
      : messageEn = 'Resource not found',
        messageMM = 'စာမျက်နှာရှာမတွေ့ပါ',
        errType = ErrType.notFoundErr,
        statusCode = 404;

  ApiException.internalServerError()
      : messageEn = 'Internal server error',
        messageMM = 'ဆာဗာတွင် ပြဿနာအချို့ ဖြစ်ပေါ်သွားပါသည်',
        errType = ErrType.serverErr,
        statusCode = 500;

  ApiException.connectionError()
      : messageEn = 'No active connection found',
        messageMM = 'အင်တာနက် ကော်နရှင် မရှိပါ',
        errType = ErrType.connectionErr,
        statusCode = 503;

  ApiException.userError({String? message})
      : messageEn = message ?? "Some input are missing or wrong",
        messageMM = message ?? "ထည့်သွင်းမှုမှားယွင်းနေပါသည်",
        errType = ErrType.userErr,
        statusCode = 422;

  ApiException.authError({String? message})
      : messageEn = message ?? "You need to authenticate first",
        messageMM = message ?? "အကောင့်ဝင်ထားရန်လိုအပ်ပါသည်",
        errType = ErrType.authErr,
        statusCode = 401;

  ApiException.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    messageEn = data['messageEn'];
    messageMM = data['messageMM'];
    statusCode = data['statusCode'];
    errType = ErrType.values.firstWhereOrNull((e) => e.name == data['errType']);
  }

  String toJson() {
    Map<String, dynamic> data = {
      'messageEn': messageEn,
      'messageMM': messageMM,
      'statusCode': statusCode,
      'errType': errType?.name,
    };
    return jsonEncode(data);
  }
}

enum ErrType {
  notFoundErr,
  serverErr,
  connectionErr,
  userErr,
  authErr,
  unknownErr,
}

''',
    'lib/network/network_log_helper.dart': '''
import 'dart:async';

extension StreamListToBytes on Stream<List<int>> {
  Future<List<int>> toBytes() async {
    final completer = Completer<List<int>>();
    final bytes = <int>[];

    listen(
      bytes.addAll,
      onDone: () => completer.complete(bytes),
      onError: completer.completeError,
    );

    return completer.future;
  }
}
''',
    'lib/utils/app_const.dart': '''
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class Spf {
  static const token = "token";
}

''',
    'lib/utils/routes.dart': '''
import 'package:get/get.dart';
import '../pages/splash/binding/splash_binding.dart';
import '../pages/splash/view/splash_page.dart';

List<GetPage> getpages = [
  GetPage(
    name: Splash.route,
    page: () => const Splash(),
    binding: SplashBinding(),
  ),
];
''',
    'lib/utils/theme.dart': '''
import "package:flutter/material.dart";
import "package:get/get.dart";

class MaterialTheme {
  static MaterialTheme constant = Get.find();

  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff650CA8),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff8C42CF),
      onPrimaryContainer: Color(0xff290c42),
      secondary: Color(0xff665a6f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffedddf6),
      onSecondaryContainer: Color(0xff211829),
      tertiary: Color(0xff805157),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd9dc),
      onTertiaryContainer: Color(0xff321016),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      background: Color(0xfffff7fe),
      onBackground: Color(0xff1e1a20),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff1e1a20),
      surfaceVariant: Color(0xffe9dfeb),
      onSurfaceVariant: Color(0xff4a454d),
      outline: Color(0xff7c757e),
      outlineVariant: Color(0xffcdc4ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inverseOnSurface: Color(0xfff7eef6),
      inversePrimary: Color(0xffdcb9f8),
      primaryFixed: Color(0xfff1dbff),
      onPrimaryFixed: Color(0xff290c42),
      primaryFixedDim: Color(0xffdcb9f8),
      onPrimaryFixedVariant: Color(0xff563a70),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff211829),
      secondaryFixedDim: Color(0xffd1c1d9),
      onSecondaryFixedVariant: Color(0xff4e4256),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff321016),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff653a40),
      surfaceDim: Color(0xffdfd8df),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff4ebf3),
      surfaceContainerHigh: Color(0xffeee6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff52366c),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff8668a1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4a3f52),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7d7086),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff61373c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff99676d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff7fe),
      onBackground: Color(0xff1e1a20),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff1e1a20),
      surfaceVariant: Color(0xffe9dfeb),
      onSurfaceVariant: Color(0xff464149),
      outline: Color(0xff635d66),
      outlineVariant: Color(0xff7f7882),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inverseOnSurface: Color(0xfff7eef6),
      inversePrimary: Color(0xffdcb9f8),
      primaryFixed: Color(0xff8668a1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff6d5087),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7d7086),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff63576c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff99676d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7e4f55),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdfd8df),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff4ebf3),
      surfaceContainerHigh: Color(0xffeee6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff301449),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff52366c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff281e30),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4a3f52),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3a171c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff61373c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffff7fe),
      onBackground: Color(0xff1e1a20),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xffe9dfeb),
      onSurfaceVariant: Color(0xff27222a),
      outline: Color(0xff464149),
      outlineVariant: Color(0xff464149),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inverseOnSurface: Color(0xffffffff),
      inversePrimary: Color(0xfff7e6ff),
      primaryFixed: Color(0xff52366c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3b2054),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4a3f52),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff33293b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff61373c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff472127),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdfd8df),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff4ebf3),
      surfaceContainerHigh: Color(0xffeee6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdcb9f8),
      surfaceTint: Color(0xffdcb9f8),
      onPrimary: Color(0xff3f2458),
      primaryContainer: Color(0xff563a70),
      onPrimaryContainer: Color(0xfff1dbff),
      secondary: Color(0xffd1c1d9),
      onSecondary: Color(0xff372c3f),
      secondaryContainer: Color(0xff4e4256),
      onSecondaryContainer: Color(0xffedddf6),
      tertiary: Color(0xfff3b7bd),
      onTertiary: Color(0xff4b252a),
      tertiaryContainer: Color(0xff653a40),
      onTertiaryContainer: Color(0xffffd9dc),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      background: Color(0xff151217),
      onBackground: Color(0xffe8e0e8),
      surface: Color(0xff151217),
      onSurface: Color(0xffe8e0e8),
      surfaceVariant: Color(0xff4a454d),
      onSurfaceVariant: Color(0xffcdc4ce),
      outline: Color(0xff968e98),
      outlineVariant: Color(0xff4a454d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inverseOnSurface: Color(0xff332f35),
      inversePrimary: Color(0xff6f528a),
      primaryFixed: Color(0xfff1dbff),
      onPrimaryFixed: Color(0xff290c42),
      primaryFixedDim: Color(0xffdcb9f8),
      onPrimaryFixedVariant: Color(0xff563a70),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff211829),
      secondaryFixedDim: Color(0xffd1c1d9),
      onSecondaryFixedVariant: Color(0xff4e4256),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff321016),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff653a40),
      surfaceDim: Color(0xff151217),
      surfaceBright: Color(0xff3c383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1e1a20),
      surfaceContainer: Color(0xff221e24),
      surfaceContainerHigh: Color(0xff2c292e),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe0bdfd),
      surfaceTint: Color(0xffdcb9f8),
      onPrimary: Color(0xff23063c),
      primaryContainer: Color(0xffa484bf),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd5c5de),
      onSecondary: Color(0xff1c1224),
      secondaryContainer: Color(0xff9a8ca2),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff8bbc1),
      onTertiary: Color(0xff2c0b11),
      tertiaryContainer: Color(0xffb88388),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff151217),
      onBackground: Color(0xffe8e0e8),
      surface: Color(0xff151217),
      onSurface: Color(0xfffff9fc),
      surfaceVariant: Color(0xff4a454d),
      onSurfaceVariant: Color(0xffd1c8d3),
      outline: Color(0xffa8a0aa),
      outlineVariant: Color(0xff88818a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inverseOnSurface: Color(0xff2c292e),
      inversePrimary: Color(0xff583c72),
      primaryFixed: Color(0xfff1dbff),
      onPrimaryFixed: Color(0xff1d0137),
      primaryFixedDim: Color(0xffdcb9f8),
      onPrimaryFixedVariant: Color(0xff452a5e),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff160d1e),
      secondaryFixedDim: Color(0xffd1c1d9),
      onSecondaryFixedVariant: Color(0xff3d3245),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff25060c),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff522a30),
      surfaceDim: Color(0xff151217),
      surfaceBright: Color(0xff3c383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1e1a20),
      surfaceContainer: Color(0xff221e24),
      surfaceContainerHigh: Color(0xff2c292e),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff9fc),
      surfaceTint: Color(0xffdcb9f8),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffe0bdfd),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9fc),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd5c5de),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffff9f9),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfff8bbc1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff151217),
      onBackground: Color(0xffe8e0e8),
      surface: Color(0xff151217),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xff4a454d),
      onSurfaceVariant: Color(0xfffff9fc),
      outline: Color(0xffd1c8d3),
      outlineVariant: Color(0xffd1c8d3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inverseOnSurface: Color(0xff000000),
      inversePrimary: Color(0xff381d51),
      primaryFixed: Color(0xfff3e0ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffe0bdfd),
      onPrimaryFixedVariant: Color(0xff23063c),
      secondaryFixed: Color(0xfff2e1fa),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd5c5de),
      onSecondaryFixedVariant: Color(0xff1c1224),
      tertiaryFixed: Color(0xffffdfe1),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff8bbc1),
      onTertiaryFixedVariant: Color(0xff2c0b11),
      surfaceDim: Color(0xff151217),
      surfaceBright: Color(0xff3c383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1e1a20),
      surfaceContainer: Color(0xff221e24),
      surfaceContainerHigh: Color(0xff2c292e),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

''',
    'lib/widgets/auth_textfield.dart': '''
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
''',
    'lib/widgets/empty.dart': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Empty extends StatelessWidget {
  final String? message;
  const Empty({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ?? "Record မရှိပါ",
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
''',
    'lib/widgets/err_widget.dart': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/api_exception.dart';
import '../utils/app_const.dart';

class ErrWidget extends StatelessWidget {
  final String? err;
  final VoidCallback? tryAgain;
  const ErrWidget({super.key, required this.err, this.tryAgain});

  @override
  Widget build(BuildContext context) {
    ApiException errors =
        err == null ? ApiException() : ApiException.fromJson(err!);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _ErrorDetail.getTitle(errors.errType ?? ErrType.unknownErr),
            style: Get.textTheme.titleMedium,
          ),
          Text(errors.messageEn ?? ''),
          const SizedBox(height: 8),
          Visibility(
            visible: tryAgain != null && errors.errType != ErrType.authErr,
            child: ElevatedButton(
              onPressed: tryAgain,
              child: const Text("Try Again"),
            ),
          ),
          Visibility(
            visible: errors.errType == ErrType.authErr,
            child: ElevatedButton(
              onPressed: () {
                box.remove(Spf.token);
                Get.offAllNamed("/");
              },
              child: const Text("Go to Login"),
            ),
          ),
        ],
      ),
    );
  }
}
class _ErrorDetail {
  static String getTitle(ErrType errType) {
    switch (errType) {
      case ErrType.authErr:
        return "Auth Error";
      case ErrType.connectionErr:
        return "No Internet Connection";
      case ErrType.notFoundErr:
        return "Request Not Found";
      case ErrType.serverErr:
        return "Server Error";
      case ErrType.userErr:
        return "User Error";
      case ErrType.unknownErr:
        return "Unknown Error";
    }
  }
}
 
 ''',
    'lib/widgets/decorated_btn.dart': '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DecoratedBtn extends StatelessWidget {
  final VoidCallback? onPress;
  final String text;
  final double? radius;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? textColor;
  final Color? borderColor;

  const DecoratedBtn({
    super.key,
    required this.onPress,
    required this.text,
    this.radius,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        maximumSize: Size(Get.width, 45),
        minimumSize: Size(Get.width * .3, 25),
        fixedSize: Size(width ?? Get.width, height ?? 40),
        backgroundColor:
            backgroundColor ?? Get.theme.colorScheme.primaryContainer,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 25),
        ),
        side: BorderSide(
          style: BorderStyle.solid,
          width: 1,
          color: borderColor ?? Get.theme.colorScheme.primaryContainer,
        ),
      ),
      onPressed: onPress,
      child: Text(
        text,
        style: Get.textTheme.labelLarge!
            .copyWith(color: textColor ?? Get.theme.colorScheme.onPrimary),
      ),
    );
  }
}

'''
  };
}
