import 'package:barberflow/core/utils/validators.dart';
import 'package:barberflow/domain/enums/tipo_usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email inválido retorna mensagem', () {
      expect(Validators.email('invalido'), isNotNull);
    });

    test('email válido retorna null', () {
      expect(Validators.email('user@barberflow.com'), isNull);
    });
  });

  group('TipoUsuario', () {
    test('fromString resolve perfis do Firestore', () {
      expect(TipoUsuario.fromString('barbeiro'), TipoUsuario.barbeiro);
      expect(TipoUsuario.fromString('dono'), TipoUsuario.dono);
      expect(TipoUsuario.fromString('cliente'), TipoUsuario.cliente);
    });
  });
}
