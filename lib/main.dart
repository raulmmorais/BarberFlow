import 'package:barberflow/app.dart';
import 'package:barberflow/core/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await initializeDateFormatting('pt_BR');
  runApp(const BarberFlowApp());
}
