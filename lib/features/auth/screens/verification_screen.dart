import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'document_verification_screen.dart';
import '../../home/screens/home_screen.dart';

class VerificationScreen extends StatefulWidget {
  final UserModel user;

  const VerificationScreen({super.key, required this.user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final List<bool> _isExpanded;
  late final ScrollController _scrollController;
  final GlobalKey _headerIconKey = GlobalKey();

  // Детальний опис кожного кроку
  final Map<String, String> _descriptions = {
    'verification':
        'Верифікація - це важливий крок для забезпечення безпеки. Підтвердження особи користувача через завантаження документів.',
    'carSearch':
        'Оберіть автомобіль з нашого широкого автопарку. Ви можете фільтрувати за маркою, моделлю та іншими параметрами.',
    'contract':
        'Ознайомтеся з умовами договору оренди та підпишіть його. Всі деталі щодо страхування та правил користування чітко прописані.',
    'payment':
        'Оплата здійснюється онлайн через захищену систему. Ми приймаємо всі основні платіжні картки.',
  };

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо список станів розкриття елементів
    _isExpanded = List.generate(4, (_) => false);
    
    // Ініціалізуємо контролер прокрутки
    _scrollController = ScrollController();
    
    // Запускаємо програмний скролінг після рендерингу віджетів
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTopEdge();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Метод для програмного скролінгу
  void _scrollToTopEdge() {
    if (_headerIconKey.currentContext != null) {
      final RenderBox box = _headerIconKey.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      
      // Розраховуємо скільки потрібно проскролити для досягнення відстані 8px 
      // від верхнього краю екрану до верхнього краю іконки
      final screenTopPadding = MediaQuery.of(context).padding.top; // SafeArea верхній відступ
      final targetOffset = position.dy - screenTopPadding - 8;
      
      if (targetOffset > 0) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Іконка верифікації
                    Container(
                      key: _headerIconKey,
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFADC3FE),
                        borderRadius: BorderRadius.circular(72),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Color(0xFF485E92),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Заголовок
                    const Text(
                      'Верифікація',
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
                      'Для початку оренди авто пройдіть\nпроцедуру підтвердження особи',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.5,
                        color: Color(0xFF44464F),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Expandable Items
                    _buildExpandableItem(
                      0,
                      'Верифікація',
                      Icons.verified_user,
                    ),
                    const SizedBox(height: 2),
                    _buildExpandableItem(
                      1,
                      'Пошук авто',
                      Icons.search,
                    ),
                    const SizedBox(height: 2),
                    _buildExpandableItem(
                      2,
                      'Підпис договору оренди',
                      Icons.description,
                    ),
                    const SizedBox(height: 2),
                    _buildExpandableItem(
                      3,
                      'Оплата оренди',
                      Icons.payment,
                    ),

                    const SizedBox(height: 40),

                    // Кнопки
                    _buildVerificationButton(),
                    const SizedBox(height: 16),
                    _buildSkipButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Створення expandable item з новим дизайном
  Widget _buildExpandableItem(
    int index, 
    String title, 
    IconData icon,
  ) {
    final String sectionId = [
      'verification',
      'carSearch',
      'contract',
      'payment',
    ][index];

    final String description = _descriptions[sectionId] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded[index] = !_isExpanded[index];
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFADC3FE),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(icon, size: 24, color: const Color(0xFF485E92)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.5,
                          color: Color(0xFF1A1B21),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded[index] ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
                if (_isExpanded[index]) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.43,
                      color: Color(0xFF44464F),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Кнопка "Пройти верифікацію" з новим дизайном
  Widget _buildVerificationButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // Тепер замість повідомлення переходимо на екран верифікації документів
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DocumentVerificationScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF485E92),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Пройти верифікацію',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Кнопка "Пропустити" з новим дизайном
  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          // Перехід на головний екран без верифікації
          _skipVerification();
        },
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
    );
  }

  // Пропустити верифікацію і перейти на головний екран
  void _skipVerification() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}
