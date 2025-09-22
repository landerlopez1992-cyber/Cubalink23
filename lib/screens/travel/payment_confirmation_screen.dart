import 'package:flutter/material.dart';
import 'package:cubalink23/models/flight_offer.dart';
import 'package:cubalink23/services/duffel_api_service.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final FlightOffer selectedOffer;
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> passengerInfo;

  const PaymentConfirmationScreen({
    super.key,
    required this.selectedOffer,
    required this.bookingData,
    required this.passengerInfo,
  });

  @override
  _PaymentConfirmationScreenState createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    final orderData = widget.bookingData['data'];
    final bookingReference = orderData['booking_reference'] ?? 'N/A';
    final orderId = orderData['id'] ?? '';

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Fondo general Cubalink23
      appBar: AppBar(
        title: Text('Confirmación de Reserva'),
        backgroundColor: Color(0xFF37474F), // Azul gris oscuro oficial Cubalink23
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Estado de la reserva
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF37474F), // Azul gris oscuro Cubalink23
                    Color(0xFF4CAF50), // Verde secciones Cubalink23
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50), // Verde éxito Cubalink23
                      size: 48,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '¡Reserva Creada!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Su vuelo ha sido reservado exitosamente',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity( 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Referencia de reserva
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF37474F).withOpacity(0.3), width: 2), // Azul gris oscuro Cubalink23
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, 
                        color: Color(0xFF4CAF50), size: 20), // Verde secciones Cubalink23
                      SizedBox(width: 8),
                      Text(
                        'Código de Reserva',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      bookingReference,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Guarde este código para futuras consultas',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Detalles del vuelo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, 
                        color: Color(0xFF4CAF50), size: 20), // Verde secciones Cubalink23
                      SizedBox(width: 8),
                      Text(
                        'Detalles del Vuelo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Aerolínea y horarios
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedOffer.airline,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${widget.selectedOffer.formattedDepartureTime} - ${widget.selectedOffer.formattedArrivalTime}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              widget.selectedOffer.stopsText,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF9800), // Naranja botones principales Cubalink23
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.selectedOffer.formattedPrice,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Información adicional
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duración',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  Text(
                                    widget.selectedOffer.formattedDuration,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estado',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                  Text(
                                    'Confirmado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
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

            SizedBox(height: 20),

            // Información del pasajero
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, 
                        color: Color(0xFF4CAF50), size: 20), // Verde secciones Cubalink23
                      SizedBox(width: 8),
                      Text(
                        'Información del Pasajero',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  _buildPassengerDetail('Nombre', '${widget.passengerInfo['given_name']} ${widget.passengerInfo['family_name']}'),
                  _buildPassengerDetail('Email', widget.passengerInfo['email']),
                  _buildPassengerDetail('Teléfono', widget.passengerInfo['phone_number']),
                  _buildPassengerDetail('Fecha de Nacimiento', widget.passengerInfo['born_on']),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Botones de acción
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _checkOrderStatus(orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF37474F), // Azul gris oscuro Cubalink23
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14), // Reducido de 16 a 14
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Verificar Estado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, 
                      '/home', 
                      (route) => false
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(vertical: 14), // Reducido de 16 a 14
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Volver al Inicio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Información adicional
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Información Importante',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Su reserva está confirmada y será procesada por la aerolínea.\n'
                    '• Recibirá un email de confirmación en breve.\n'
                    '• Llegue al aeropuerto con 2 horas de anticipación.\n'
                    '• Tenga su documento de identidad válido.',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkOrderStatus(String orderId) async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      print('🔍 Verificando estado de la orden: $orderId');
      
      final orderStatus = await DuffelApiService.getOrderStatus(orderId);
      
      if (orderStatus != null) {
        final status = orderStatus['data']['booking_reference'] ?? 'Unknown';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado: Reserva confirmada ($status)'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo verificar el estado. Intente más tarde.'),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error verificando estado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar estado: ${e.toString()}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}