// Removed cloud_firestore import - using Supabase instead

enum ReportType {
  vendor,
  product,
  service,
}

enum ReportStatus {
  pending,
  reviewed,
  resolved,
}

class VendorReport {
  final String id;
  final String vendorId;
  final String reporterId;
  final String? productId;
  final ReportType reportType;
  final String reason;
  final String? description;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorReport({
    required this.id,
    required this.vendorId,
    required this.reporterId,
    this.productId,
    required this.reportType,
    required this.reason,
    this.description,
    this.status = ReportStatus.pending,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorReport.fromJson(Map<String, dynamic> json) {
    return VendorReport(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      reporterId: json['reporter_id'] ?? '',
      productId: json['product_id'],
      reportType: _parseReportType(json['report_type']),
      reason: json['reason'] ?? '',
      description: json['description'],
      status: _parseReportStatus(json['status']),
      adminNotes: json['admin_notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'reporter_id': reporterId,
      'product_id': productId,
      'report_type': reportType.name,
      'reason': reason,
      'description': description,
      'status': status.name,
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VendorReport copyWith({
    String? id,
    String? vendorId,
    String? reporterId,
    String? productId,
    ReportType? reportType,
    String? reason,
    String? description,
    ReportStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorReport(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      reporterId: reporterId ?? this.reporterId,
      productId: productId ?? this.productId,
      reportType: reportType ?? this.reportType,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters útiles
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasAdminNotes => adminNotes != null && adminNotes!.isNotEmpty;
  bool get isPending => status == ReportStatus.pending;
  bool get isReviewed => status == ReportStatus.reviewed;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isProductReport => reportType == ReportType.product;
  bool get isVendorReport => reportType == ReportType.vendor;
  bool get isServiceReport => reportType == ReportType.service;

  String get statusText {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.reviewed:
        return 'Revisado';
      case ReportStatus.resolved:
        return 'Resuelto';
    }
  }

  String get typeText {
    switch (reportType) {
      case ReportType.vendor:
        return 'Vendedor';
      case ReportType.product:
        return 'Producto';
      case ReportType.service:
        return 'Servicio';
    }
  }

  String get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return 'orange';
      case ReportStatus.reviewed:
        return 'blue';
      case ReportStatus.resolved:
        return 'green';
    }
  }

  @override
  String toString() {
    return 'VendorReport(id: $id, type: $reportType, status: $status, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorReport && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Métodos estáticos para parsing
  static ReportType _parseReportType(String? type) {
    switch (type) {
      case 'vendor':
        return ReportType.vendor;
      case 'product':
        return ReportType.product;
      case 'service':
        return ReportType.service;
      default:
        return ReportType.vendor;
    }
  }

  static ReportStatus _parseReportStatus(String? status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      default:
        return ReportStatus.pending;
    }
  }
}
