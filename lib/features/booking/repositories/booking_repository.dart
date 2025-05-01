import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firebase_service.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseService _firebaseService = FirebaseService();
  CollectionReference get _bookingsCollection => _firebaseService.firestore.collection('bookings');

  // Create a new booking
  Future<String> createBooking({
    required String carId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final bookingData = {
      'carId': carId,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': BookingStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'adminNote': null,
    };

    final docRef = await _bookingsCollection.add(bookingData);
    return docRef.id;
  }

  // Get bookings for a specific user
  Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get active bookings for a specific user (not cancelled or rejected)
  Stream<List<Booking>> getUserActiveBookingsStream(String userId) {
    // Simpler query that doesn't require the complex index
    return _bookingsCollection.where('userId', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      print("testr $snapshot");
      
      // Create a list to hold our booking results
      List<Booking> bookings = [];
      
      // Process each document asynchronously
      for (var doc in snapshot.docs) {
        try {
          // Get the full document with an async call
          final fullDocSnapshot = await doc.reference.get();
          final data = fullDocSnapshot.data() as Map<String, dynamic>;
          
          // Print the full document data to debug
          print("Full booking data: ${doc.id} => $data");
          
          // Create a booking from the fetched data
          final booking = Booking.fromFirestore(doc.id, data);
          bookings.add(booking);
          
          print("Successfully processed booking: ${doc.id}, carId: ${booking.carId}");
        } catch (e) {
          print("Error fetching full booking document: $e");
          // Still add the booking from the original snapshot as a fallback
          final data = doc.data() as Map<String, dynamic>;
          print("Fallback booking data: ${doc.id} => $data");
          bookings.add(Booking.fromFirestore(doc.id, data));
        }
      }
      
      return bookings;
    });
    
    // Original query - uncomment when index is ready
    /*
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereNotIn: [
          BookingStatus.cancelled.name,
          BookingStatus.rejected.name
        ])
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
    */
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    if (!doc.exists) return null;

    return Booking.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Get bookings by car ID
  Stream<List<Booking>> getBookingsByCarIdStream(String carId) {
    return _bookingsCollection
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: [BookingStatus.pending.name, BookingStatus.approved.name])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Booking.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // Check if car is available for booking in a specific date range
  Future<bool> isCarAvailableForBooking(String carId, DateTime startDate, DateTime endDate) async {
    final snapshot = await _bookingsCollection
        .where('carId', isEqualTo: carId)
        .where('status', whereIn: [BookingStatus.pending.name, BookingStatus.approved.name]).get();

    if (snapshot.docs.isEmpty) return true;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final bookedStartDate = (data['startDate'] as Timestamp).toDate();
      final bookedEndDate = (data['endDate'] as Timestamp).toDate();

      // Check if there's any overlap with existing bookings
      if (!(endDate.isBefore(bookedStartDate) || startDate.isAfter(bookedEndDate))) {
        return false;
      }
    }

    return true;
  }
}
