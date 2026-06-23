import 'package:barberflow/core/constants/firestore_collections.dart';
import 'package:barberflow/core/errors/app_exception.dart';
import 'package:barberflow/data/models/usuario_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  '697711167014-h6hjgq4q1o3f036gv71flnj6a7iv9o0i.apps.googleusercontent.com',
            );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required UsuarioModel usuario,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _saveUsuario(uid, usuario);
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao criar conta.');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    }
  }

  Future<void> saveUsuarioProfile(UsuarioModel usuario) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw AppException('Sessão expirada. Faça login novamente.');
    }
    try {
      await _saveUsuario(uid, usuario);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Erro ao salvar perfil.');
    }
  }

  Future<bool> hasUsuarioProfile(String uid) async {
    final doc = await _firestore
        .collection(FirestoreCollections.usuarios)
        .doc(uid)
        .get();
    return doc.exists;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> _saveUsuario(String uid, UsuarioModel usuario) async {
    await _firestore
        .collection(FirestoreCollections.usuarios)
        .doc(uid)
        .set(usuario.copyWithUid(uid).toFirestore());
  }

  String _mapAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-credential' => 'Credenciais inválidas. Verifique e-mail e senha.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'invalid-email' => 'E-mail inválido.',
      'weak-password' => 'Senha muito fraca.',
      'account-exists-with-different-credential' =>
        'Este e-mail já está vinculado a outro método de login.',
      _ => 'Falha na autenticação. Tente novamente.',
    };
  }
}

extension on UsuarioModel {
  UsuarioModel copyWithUid(String uid) {
    return UsuarioModel(
      uid: uid,
      nome: nome,
      telefone: telefone,
      tipo: tipo,
      idEstabelecimento: idEstabelecimento,
      isMensalista: isMensalista,
      mensalidadePaga: mensalidadePaga,
      diaVencimento: diaVencimento,
    );
  }
}
