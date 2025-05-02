import 'package:flutter/material.dart';
import 'package:rentsoft_app/features/auth/models/user_model.dart';

class VerificationStatusWidget extends StatelessWidget {
  final VerificationStatus status;

  const VerificationStatusWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Визначаємо параметри для кожного статусу
    late final Color backgroundColor;
    late final Color borderColor;
    late final IconData icon;
    late final Color iconColor;
    late final String statusText;
    late final TextStyle textStyle;

    switch (status) {
      case VerificationStatus.verified:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        icon = Icons.verified_user;
        iconColor = Colors.green.shade700;
        statusText = 'Верифіковано';
        textStyle = const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Colors.green
        );
        break;
      
      case VerificationStatus.pending:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade200;
        icon = Icons.pending_outlined;
        iconColor = Colors.orange.shade700;
        statusText = 'На перевірці';
        textStyle = const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Colors.orange
        );
        break;
        
      case VerificationStatus.notVerified:
      default:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.red.shade700;
        statusText = 'Аккаунт не верифіковано';
        textStyle = const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold, 
          color: Colors.red
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              statusText,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
