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

