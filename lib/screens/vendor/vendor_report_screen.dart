import 'package:flutter/material.dart';
import 'package:cubalink23/models/vendor_report.dart';
import 'package:cubalink23/services/vendor_report_service.dart';
import 'package:cubalink23/services/auth_service_bypass.dart';

class VendorReportScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String? productId;

  const VendorReportScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    this.productId,
  });

  @override
  _VendorReportScreenState createState() => _VendorReportScreenState();
}

class _VendorReportScreenState extends State<VendorReportScreen> {
  final VendorReportService _reportService = VendorReportService();
  final TextEditingController _descriptionController = TextEditingController();
  
  ReportType _selectedType = ReportType.vendor;
  String _selectedReason = '';
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Producto de mala calidad',
    'Producto no coincide con la descripción',
    'Vendedor no responde',
    'Problema con la entrega',
    'Precio incorrecto',
    'Producto dañado',
    'Servicio al cliente deficiente',
    'Información falsa',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    // Si se proporciona productId, establecer tipo como producto
    if (widget.productId != null) {
      _selectedType = ReportType.product;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportar Vendedor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.report_problem, color: Colors.red, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reportar: ${widget.vendorName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                        Text(
                          'Ayúdanos a mantener la calidad de la plataforma',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Report type selection
            _buildReportTypeSection(),
            
            SizedBox(height: 24),
            
            // Reason selection
            _buildReasonSection(),
            
            SizedBox(height: 24),
            
            // Description section
            _buildDescriptionSection(),
            
            SizedBox(height: 32),
            
            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Reporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...ReportType.values.map((type) {
          return RadioListTile<ReportType>(
            title: Text(_getReportTypeText(type)),
            subtitle: Text(_getReportTypeDescription(type)),
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _selectedReason = ''; // Reset reason when type changes
              });
            },
            activeColor: Theme.of(context).primaryColor,
          );
        }),
      ],
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivo del Reporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value!;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción Detallada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Proporciona más detalles sobre el problema (opcional pero recomendado)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe el problema en detalle...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedReason.isNotEmpty && !_isSubmitting ? _submitReport : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Enviando...'),
                ],
              )
            : Text(
                'Enviar Reporte',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _getReportTypeText(ReportType type) {
    switch (type) {
      case ReportType.vendor:
        return 'Vendedor';
      case ReportType.product:
        return 'Producto';
      case ReportType.service:
        return 'Servicio';
    }
  }

  String _getReportTypeDescription(ReportType type) {
    switch (type) {
      case ReportType.vendor:
        return 'Problema con el vendedor en general';
      case ReportType.product:
        return 'Problema específico con un producto';
      case ReportType.service:
        return 'Problema con el servicio de atención';
    }
  }

  Future<void> _submitReport() async {
    if (_selectedReason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona un motivo para el reporte'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = AuthServiceBypass.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final report = VendorReport(
        id: '',
        vendorId: widget.vendorId,
        reporterId: currentUser.id,
        productId: widget.productId,
        reportType: _selectedType,
        reason: _selectedReason,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _reportService.createReport(report);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Reporte enviado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Retornar true para indicar éxito
      } else {
        throw Exception('Error al enviar reporte');
      }
    } catch (e) {
      print('❌ Error enviando reporte: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al enviar reporte: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
