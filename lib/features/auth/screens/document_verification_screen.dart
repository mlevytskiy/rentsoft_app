import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../models/user_model.dart';
import '../repositories/mock_auth_repository.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/di/service_locator.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  final List<File> _documentImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _documentImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: ${e.toString()}')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Обрати фото'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Камера'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _documentImages.removeAt(index);
    });
  }

  Future<void> _submitDocuments() async {
    if (_documentImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Додайте хоча б одне фото документа')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Отримуємо інстанцію репозиторію
      final authRepository = getIt<MockAuthRepository>();
      
      // Оновлюємо статус користувача на "на перевірці"
      final updatedUser = await authRepository.updateVerificationStatus(VerificationStatus.pending);
      
      if (updatedUser != null) {
        // Імітація відправки фотографій на сервер
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          // Оновлюємо стан користувача в BloC
          context.read<AuthBloc>().add(AuthCheckStatusEvent());
          
          // Повідомляємо про успішну відправку
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Документи відправлені на перевірку')),
          );
          
          // Перенаправляємо на головний екран
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при відправці документів: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipVerification() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Іконка документів
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFADC3FE),
                        borderRadius: BorderRadius.circular(72),
                      ),
                      child: const Icon(
                        Icons.file_present,
                        color: Color(0xFF485E92),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Заголовок
                    const Text(
                      'Документи',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1B21),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Підзаголовок
                    const Text(
                      'Прикріпіть паспорт або водійські права для перевірки',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.5,
                        color: Color(0xFF44464F),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Відображення завантажених зображень
                    if (_documentImages.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Завантажені документи:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF485E92),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _documentImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _documentImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close, 
                                            size: 20, 
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Кнопка додавання документів
                    InkWell(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFADC3FE)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFADC3FE).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: Color(0xFF485E92),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Додати фото документа',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF485E92),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Паспорт, ID-картка або водійські права',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF44464F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Кнопка "Відправити на перевірку"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitDocuments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF485E92),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Відправити на перевірку',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Кнопка "Пропустити"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _skipVerification,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF485E92),
                          side: const BorderSide(color: Color(0xFF757780)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Пропустити',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
