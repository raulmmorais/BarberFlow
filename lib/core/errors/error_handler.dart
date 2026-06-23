import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  ErrorHandler._();

  static String getMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  static void show(BuildContext context, Object error) {
    SnackbarUtils.showError(context, getMessage(error));
  }
}
