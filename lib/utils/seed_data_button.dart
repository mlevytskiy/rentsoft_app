import 'package:flutter/material.dart';
import 'seed_data.dart';

class SeedDataButton extends StatefulWidget {
  const SeedDataButton({super.key});

  @override
  State<SeedDataButton> createState() => _SeedDataButtonState();
}

class _SeedDataButtonState extends State<SeedDataButton> {
  bool _isLoading = false;
  
  void _seedData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final seedData = SeedData();
      await seedData.seedDataForTesting();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test data added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding test data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isLoading ? null : _seedData,
      backgroundColor: Colors.amber,
      child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.data_array),
    );
  }
}
