import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class Booking {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final DateTime createdAt;
  final String? adminNote;

  Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    this.adminNote,
  });

  factory Booking.fromFirestore(String id, Map<String, dynamic> data) {
    // Handle the case where timestamps might be null
    final startDateTimestamp = data['startDate'] as Timestamp?;
    final endDateTimestamp = data['endDate'] as Timestamp?;
    final createdAtTimestamp = data['createdAt'] as Timestamp?;
    
    // Handle carId which might be a number, string, or other format
    String carId;
    final rawCarId = data['carId'];
    if (rawCarId is String) {
      carId = rawCarId;
    } else if (rawCarId is int) {
      carId = rawCarId.toString();
    } else if (rawCarId is num) {
      carId = rawCarId.toString();
    } else if (rawCarId == null) {
      carId = 'unknown';
    } else {
      carId = rawCarId.toString();
    }
    
    // Print debug info about carId
    print("Raw carId type: ${rawCarId.runtimeType}, value: $rawCarId, converted to: $carId");
    
    return Booking(
      id: id,
      carId: carId,
      userId: data['userId'] as String,
      startDate: startDateTimestamp != null ? startDateTimestamp.toDate() : DateTime.now(),
      endDate: endDateTimestamp != null ? endDateTimestamp.toDate() : DateTime.now().add(const Duration(days: 7)),
      status: data['status'] != null 
          ? BookingStatus.values.byName(data['status'] as String)
          : BookingStatus.pending,
      createdAt: createdAtTimestamp != null ? createdAtTimestamp.toDate() : DateTime.now(),
      adminNote: data['adminNote'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carId': carId,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'adminNote': adminNote,
    };
  }

  Booking copyWith({
    String? id,
    String? carId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus? status,
    DateTime? createdAt,
    String? adminNote,
  }) {
    return Booking(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}
