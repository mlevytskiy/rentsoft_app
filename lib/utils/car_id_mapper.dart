import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to handle mapping between simple numeric IDs and Firestore document IDs
class CarIdMapper {
  // Static instance for singleton access
  static final CarIdMapper _instance = CarIdMapper._internal();
  factory CarIdMapper() => _instance;
  CarIdMapper._internal();

  // Firestore reference to the cars collection
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _carsCollection => _firestore.collection('cars');
  
  // Map to cache ID mappings
  final Map<String, String> _simpleToFirestoreIds = {};
  final Map<String, String> _firestoreToSimpleIds = {};
  bool _isInitialized = false;

  /// Initialize the mapper by loading all cars from Firestore
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Clear existing mappings
      _simpleToFirestoreIds.clear();
      _firestoreToSimpleIds.clear();
      
      // Fetch all cars from Firestore
      final carsSnapshot = await _carsCollection.get();
      
      // Create mappings
      int simpleId = 1;
      for (final doc in carsSnapshot.docs) {
        final firestoreId = doc.id;
        final simplifiedId = simpleId.toString();
        
        _simpleToFirestoreIds[simplifiedId] = firestoreId;
        _firestoreToSimpleIds[firestoreId] = simplifiedId;
        
        simpleId++;
      }
      
      _isInitialized = true;
      print('CarIdMapper initialized with ${_simpleToFirestoreIds.length} mappings');
      _simpleToFirestoreIds.forEach((k, v) => print('Simple: $k -> Firestore: $v'));
    } catch (e) {
      print('Error initializing CarIdMapper: $e');
    }
  }
  
  /// Convert a simple ID (e.g., "8") to a Firestore document ID
  /// Returns null if no mapping is found
  String? getFirestoreId(String simpleId) {
    if (!_isInitialized) {
      print('WARNING: CarIdMapper not initialized before use');
      return null;
    }
    
    // First try a direct lookup
    if (_simpleToFirestoreIds.containsKey(simpleId)) {
      return _simpleToFirestoreIds[simpleId];
    }
    
    // If that fails, try to interpret it as an integer index
    try {
      final index = int.parse(simpleId);
      if (index > 0 && index <= _simpleToFirestoreIds.length) {
        final key = index.toString();
        return _simpleToFirestoreIds[key];
      }
    } catch (e) {
      // Not a valid integer, ignore
    }
    
    // If all else fails, check if the simple ID is already a valid Firestore ID
    if (_firestoreToSimpleIds.containsKey(simpleId)) {
      return simpleId; // It's already a Firestore ID
    }
    
    print('No mapping found for simple ID: $simpleId');
    return null;
  }
  
  /// Convert a Firestore document ID to a simple ID
  /// Returns null if no mapping is found
  String? getSimpleId(String firestoreId) {
    if (!_isInitialized) {
      print('WARNING: CarIdMapper not initialized before use');
      return null;
    }
    
    // Try direct lookup
    if (_firestoreToSimpleIds.containsKey(firestoreId)) {
      return _firestoreToSimpleIds[firestoreId];
    }
    
    // Check if it's already a simple ID
    if (_simpleToFirestoreIds.containsKey(firestoreId)) {
      return firestoreId; // It's already a simple ID
    }
    
    print('No mapping found for Firestore ID: $firestoreId');
    return null;
  }
  
  /// Get all available car IDs in both simple and Firestore formats
  Map<String, String> getAllMappings() {
    return Map.from(_simpleToFirestoreIds);
  }
  
  /// Add a new mapping or update an existing one
  void addMapping(String simpleId, String firestoreId) {
    _simpleToFirestoreIds[simpleId] = firestoreId;
    _firestoreToSimpleIds[firestoreId] = simpleId;
  }
  
  /// Reset all mappings (for testing or reconfiguration)
  void reset() {
    _simpleToFirestoreIds.clear();
    _firestoreToSimpleIds.clear();
    _isInitialized = false;
  }
}
