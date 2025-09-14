import 'package:flutter/foundation.dart';
import 'package:cubalink23/models/vendor_report.dart';
import 'package:cubalink23/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VendorReportService extends ChangeNotifier {
  static final VendorReportService _instance = VendorReportService._internal();
  factory VendorReportService() => _instance;
  VendorReportService._internal();

  final SupabaseClient? _client = SupabaseConfig.client;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Crear nuevo reporte
  Future<bool> createReport(VendorReport report) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('📝 Creando reporte para vendedor: ${report.vendorId}');

      final reportData = report.toJson();
      // Remover campos que se generan automáticamente
      reportData.remove('id');
      reportData.remove('created_at');
      reportData.remove('updated_at');

      final response = await _client
          .from('vendor_reports')
          .insert(reportData);

      print('✅ Reporte creado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error creando reporte: $e');
      return false;
    }
  }

  /// Obtener reportes de un vendedor
  Future<List<VendorReport>> getVendorReports(String vendorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('📝 Cargando reportes del vendedor: $vendorId');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      final reports = response.map<VendorReport>((data) => 
          VendorReport.fromJson(data)).toList();

      print('✅ ${reports.length} reportes cargados');
      return reports;
    } catch (e) {
      print('❌ Error cargando reportes: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener todos los reportes (para admin)
  Future<List<VendorReport>> getAllReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('📝 Cargando todos los reportes...');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .order('created_at', ascending: false);

      final reports = response.map<VendorReport>((data) => 
          VendorReport.fromJson(data)).toList();

      print('✅ ${reports.length} reportes cargados');
      return reports;
    } catch (e) {
      print('❌ Error cargando reportes: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener reportes por estado
  Future<List<VendorReport>> getReportsByStatus(ReportStatus status) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('📝 Cargando reportes con estado: ${status.name}');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .eq('status', status.name)
          .order('created_at', ascending: false);

      final reports = response.map<VendorReport>((data) => 
          VendorReport.fromJson(data)).toList();

      print('✅ ${reports.length} reportes con estado ${status.name} cargados');
      return reports;
    } catch (e) {
      print('❌ Error cargando reportes por estado: $e');
      return [];
    }
  }

  /// Actualizar estado del reporte (admin only)
  Future<bool> updateReportStatus(String reportId, ReportStatus newStatus, {String? adminNotes}) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return false;
      }

      print('📝 Actualizando estado del reporte: $reportId');

      final updateData = {
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null) {
        updateData['admin_notes'] = adminNotes;
      }

      final response = await _client
          .from('vendor_reports')
          .update(updateData)
          .eq('id', reportId);

      print('✅ Estado del reporte actualizado exitosamente');
      return true;
    } catch (e) {
      print('❌ Error actualizando estado del reporte: $e');
      return false;
    }
  }

  /// Obtener reporte por ID
  Future<VendorReport?> getReportById(String reportId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return null;
      }

      print('📝 Obteniendo reporte: $reportId');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .eq('id', reportId)
          .single();

      final report = VendorReport.fromJson(response);
      print('✅ Reporte encontrado');
      return report;
    
      return null;
    } catch (e) {
      print('❌ Error obteniendo reporte: $e');
      return null;
    }
  }

  /// Obtener estadísticas de reportes
  Future<Map<String, int>> getReportStats() async {
    try {
      if (_client == null) {
        return {};
      }

      print('📊 Obteniendo estadísticas de reportes...');

      final allReports = await getAllReports();
      
      final stats = <String, int>{
        'total': allReports.length,
        'pending': 0,
        'reviewed': 0,
        'resolved': 0,
      };

      for (final report in allReports) {
        switch (report.status) {
          case ReportStatus.pending:
            stats['pending'] = (stats['pending'] ?? 0) + 1;
            break;
          case ReportStatus.reviewed:
            stats['reviewed'] = (stats['reviewed'] ?? 0) + 1;
            break;
          case ReportStatus.resolved:
            stats['resolved'] = (stats['resolved'] ?? 0) + 1;
            break;
        }
      }

      print('✅ Estadísticas calculadas: $stats');
      return stats;
    } catch (e) {
      print('❌ Error calculando estadísticas: $e');
      return {};
    }
  }

  /// Obtener reportes recientes
  Future<List<VendorReport>> getRecentReports({int limit = 20}) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('📝 Cargando reportes recientes...');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      final reports = response.map<VendorReport>((data) => 
          VendorReport.fromJson(data)).toList();

      print('✅ ${reports.length} reportes recientes cargados');
      return reports;
    } catch (e) {
      print('❌ Error cargando reportes recientes: $e');
      return [];
    }
  }

  /// Verificar si un usuario ya reportó a un vendedor
  Future<bool> hasUserReportedVendor(String userId, String vendorId) async {
    try {
      if (_client == null) {
        return false;
      }

      final response = await _client
          .from('vendor_reports')
          .select('id')
          .eq('reporter_id', userId)
          .eq('vendor_id', vendorId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error verificando si usuario reportó vendedor: $e');
      return false;
    }
  }

  /// Obtener reportes de un usuario específico
  Future<List<VendorReport>> getUserReports(String userId) async {
    try {
      if (_client == null) {
        print('⚠️ Supabase no disponible');
        return [];
      }

      print('📝 Cargando reportes del usuario: $userId');

      final response = await _client
          .from('vendor_reports')
          .select('*')
          .eq('reporter_id', userId)
          .order('created_at', ascending: false);

      final reports = response.map<VendorReport>((data) => 
          VendorReport.fromJson(data)).toList();

      print('✅ ${reports.length} reportes del usuario cargados');
      return reports;
    } catch (e) {
      print('❌ Error cargando reportes del usuario: $e');
      return [];
    }
  }
}
