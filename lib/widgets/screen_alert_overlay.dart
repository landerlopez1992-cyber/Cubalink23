import 'package:flutter/material.dart';
import 'package:cubalink23/services/supabase_service.dart';

class ScreenAlertOverlay extends StatefulWidget {
  final Widget child;

  const ScreenAlertOverlay({super.key, required this.child});

  @override
  _ScreenAlertOverlayState createState() => _ScreenAlertOverlayState();
}

class _ScreenAlertOverlayState extends State<ScreenAlertOverlay> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  Map<String, dynamic>? _currentAlert;
  bool _showingAlert = false;

  @override
  void initState() {
    super.initState();
    _checkForAlert();
  }

  _checkForAlert() async {
    try {
      // Simulando datos de alerta para evitar error mientras se implementa método
      final alert = null; // await _supabaseService.getScreenAlert();
      if (alert != null && !_showingAlert) {
        setState(() {
          _currentAlert = alert;
          _showingAlert = true;
        });
        _showAlertDialog();
      }
    } catch (e) {
      print('Error checking for screen alert: $e');
    }
  }

  _showAlertDialog() {
    if (_currentAlert == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity( 0.8),
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(16),
                child: IconButton(
                  onPressed: _dismissAlert,
                  icon: Icon(Icons.close, size: 30),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity( 0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),

              // Content
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Alert Icon
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 50,
                          color: Colors.amber[700],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Alert Image (if provided)
                      if (_currentAlert!['image_url'] != null && 
                          _currentAlert!['image_url'].toString().isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _currentAlert!['image_url'],
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],

                      // Alert Message
                      Text(
                        _currentAlert!['message'] ?? 'Alerta importante',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      // Acknowledge Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dismissAlert,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Entendido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dismissAlert() async {
    try {
      // Simulando dismissal de alerta para evitar error mientras se implementa método
      // await _supabaseService.dismissScreenAlert();
      setState(() {
        _currentAlert = null;
        _showingAlert = false;
      });
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error dismissing alert: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}