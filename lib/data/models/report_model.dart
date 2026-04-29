class ReportModel {
  final String? id;
  final String? imagePath;
  final String? park;
  final String? reportType;
  final String? notes;
  final String? phone;

  ReportModel({
    this.id,
    this.imagePath,
    this.park,
    this.reportType,
    this.notes,
    this.phone,
  });

  // Copy with method for immutability
  ReportModel copyWith({
    String? id,
    String? imagePath,
    String? park,
    String? reportType,
    String? notes,
    String? phone,
  }) {
    return ReportModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      park: park ?? this.park,
      reportType: reportType ?? this.reportType,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'park': park,
      'reportType': reportType,
      'notes': notes,
      'phone': phone,
    };
  }

  // Create from JSON (for API responses)
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String?,
      imagePath: json['imagePath'] as String?,
      park: json['park'] as String?,
      reportType: json['reportType'] as String?,
      notes: json['notes'] as String?,
      phone: json['phone'] as String?,
    );
  }

  // Check if all required fields are filled
  bool isValid() {
    return imagePath != null &&
        imagePath!.isNotEmpty &&
        park != null &&
        park!.isNotEmpty &&
        reportType != null &&
        reportType!.isNotEmpty &&
        notes != null &&
        notes!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty;
  }
}
