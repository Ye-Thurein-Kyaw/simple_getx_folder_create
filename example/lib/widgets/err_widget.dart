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
