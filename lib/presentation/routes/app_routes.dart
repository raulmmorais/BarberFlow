import 'package:barberflow/core/constants/route_names.dart';
import 'package:barberflow/presentation/auth/screens/complete_profile_screen.dart';
import 'package:barberflow/presentation/auth/screens/login_screen.dart';
import 'package:barberflow/presentation/auth/screens/register_screen.dart';
import 'package:barberflow/presentation/client/screens/booking_datetime_screen.dart';
import 'package:barberflow/presentation/client/screens/client_home_screen.dart';
import 'package:barberflow/presentation/client/screens/history_screen.dart';
import 'package:barberflow/presentation/client/screens/mensalidade_screen.dart';
import 'package:barberflow/presentation/client/screens/my_appointments_screen.dart';
import 'package:barberflow/presentation/client/screens/reminder_settings_screen.dart';
import 'package:barberflow/presentation/manager/screens/barber_dashboard_screen.dart';
import 'package:barberflow/presentation/manager/screens/barbers_crud_screen.dart';
import 'package:barberflow/presentation/manager/screens/manual_booking_screen.dart';
import 'package:barberflow/presentation/manager/screens/mensalistas_screen.dart';
import 'package:barberflow/presentation/manager/screens/owner_establishment_screen.dart';
import 'package:barberflow/presentation/manager/screens/services_crud_screen.dart';
import 'package:barberflow/presentation/shared/screens/root_page.dart';
import 'package:barberflow/presentation/shared/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static Map<String, WidgetBuilder> get routes => {
        RouteNames.splash: (_) => const SplashScreen(),
        RouteNames.login: (_) => const LoginScreen(),
        RouteNames.register: (_) => const RegisterScreen(),
        RouteNames.completeProfile: (_) => const CompleteProfileScreen(),
        RouteNames.root: (_) => const RootPage(),
        RouteNames.clientHome: (_) => const ClientHomeScreen(),
        RouteNames.bookingDateTime: (_) => const BookingDateTimeScreen(),
        RouteNames.myAppointments: (_) => const MyAppointmentsScreen(),
        RouteNames.history: (_) => const HistoryScreen(),
        RouteNames.mensalidade: (_) => const MensalidadeScreen(),
        RouteNames.reminderSettings: (_) => const ReminderSettingsScreen(),
        RouteNames.barberDashboard: (_) => const BarberDashboardScreen(),
        RouteNames.manualBooking: (_) => const ManualBookingScreen(),
        RouteNames.mensalistas: (_) => const MensalistasScreen(),
        RouteNames.ownerEstablishment: (_) => const OwnerEstablishmentScreen(),
        RouteNames.servicesCrud: (_) => const ServicesCrudScreen(),
        RouteNames.barbersCrud: (_) => const BarbersCrudScreen(),
      };
}
