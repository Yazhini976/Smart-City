class Complaint {
  final String complaintId;
  final int moduleId;
  final int wardNo;
  final int? assignedOfficerId;
  final double latitude;
  final double longitude;
  final String street;
  final String area;
  final String city;
  final String title;
  final String description;
  final String photoUrl;
  final String status;
  final DateTime createdAt;

  Complaint({
    required this.complaintId,
    required this.moduleId,
    required this.wardNo,
    this.assignedOfficerId,
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.area,
    required this.city,
    required this.title,
    required this.description,
    required this.photoUrl,
    required this.status,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      complaintId: json['complaint_id'] ?? '',
      moduleId: json['module_id'] ?? 0,
      wardNo: json['ward_no'] ?? 0,
      assignedOfficerId: json['assigned_officer_id'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class WorkOrder {
  final String workOrderId;
  final String complaintId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String? rejectionReason;
  final DateTime assignedAt;
  final DateTime? completedAt;

  WorkOrder({
    required this.workOrderId,
    required this.complaintId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.rejectionReason,
    required this.assignedAt,
    this.completedAt,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      workOrderId: json['work_order_id'] ?? '',
      complaintId: json['complaint_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      rejectionReason: json['rejection_reason'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}