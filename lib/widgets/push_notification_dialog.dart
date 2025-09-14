import 'package:flutter/material.dart';

class PushNotificationDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isUrgent;
  final VoidCallback onAccept;
  final VoidCallback? onDismiss;

  const PushNotificationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.isUrgent,
    required this.onAccept,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isUrgent ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con icono
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isUrgent ? Icons.priority_high : Icons.notifications,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isUrgent ? 'Notificación Urgente' : 'Nueva Notificación',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.red.shade800 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Mensaje
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isUrgent ? Colors.red.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUrgent ? Colors.red.shade200 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUrgent ? Colors.red.shade700 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botones
                  Row(
                    children: [
                      if (onDismiss != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDismiss,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isUrgent ? Colors.red : Colors.grey,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cerrar',
                              style: TextStyle(
                                color: isUrgent ? Colors.red : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrgent ? Colors.red : Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar el diálogo de notificación
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool isUrgent = false,
    VoidCallback? onAccept,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (BuildContext context) {
        return PushNotificationDialog(
          title: title,
          message: message,
          isUrgent: isUrgent,
          onAccept: () {
            Navigator.of(context).pop();
            onAccept?.call();
          },
          onDismiss: onDismiss != null ? () {
            Navigator.of(context).pop();
            onDismiss.call();
          } : null,
        );
      },
    );
  }
}


