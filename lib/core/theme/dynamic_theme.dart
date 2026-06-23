import 'package:barberflow/core/theme/app_theme.dart';
import 'package:barberflow/domain/entities/estabelecimento.dart';
import 'package:flutter/material.dart';

class DynamicTheme {
  DynamicTheme._();

  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static ThemeData fromEstabelecimento(Estabelecimento? estabelecimento) {
    if (estabelecimento == null) {
      return AppTheme.light();
    }
    return AppTheme.light(
      primary: _hexToColor(estabelecimento.corPrimaria),
      secondary: _hexToColor(estabelecimento.corSecundaria),
    );
  }
}
