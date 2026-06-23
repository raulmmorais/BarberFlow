import 'package:barberflow/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppointmentActionButtons extends StatelessWidget {
  const AppointmentActionButtons({
    super.key,
    required this.onConfirm,
    required this.onReject,
  });

  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Confirmar agendamento',
          isLarge: true,
          icon: Icons.check_circle,
          onPressed: onConfirm,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Recusar agendamento',
          isLarge: true,
          icon: Icons.cancel,
          onPressed: onReject,
        ),
      ],
    );
  }
}
