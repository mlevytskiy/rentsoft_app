import 'package:flutter/material.dart';

import '../../../core/services/api_config_service.dart';

// Enum для опцій URL
enum UrlOption {
  localhost,
  ourPublic,
  withoutInternet,
  custom,
}

// Enum для сценаріїв використання
enum UsageScenario {
  allFleets, // Доступні всі автопарки
  singleFleet, // Тільки один автопарк
}

class SecretScreen extends StatefulWidget {
  const SecretScreen({super.key});

  @override
  State<SecretScreen> createState() => _SecretScreenState();
}

class _SecretScreenState extends State<SecretScreen> {
  final ApiConfigService _apiConfigService = ApiConfigService();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _fleetIdController = TextEditingController(); // Контролер для поля ID автопарка
  UrlOption _selectedOption = UrlOption.ourPublic; // За замовчуванням публічний URL
  UsageScenario _selectedScenario = UsageScenario.allFleets; // За замовчуванням всі автопарки
  bool _isLoading = false;

  // Мапа для зберігання URL для кожної опції
  final Map<UrlOption, String> _urlOptions = {
    UrlOption.localhost: 'http://localhost:8888/',
    UrlOption.ourPublic: 'http://rentsoft-env-1.eba-xkfjndpj.us-east-1.elasticbeanstalk.com/api/',
    UrlOption.withoutInternet: 'no-internet',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
    _loadFleetId(); // Завантажуємо збережений ID автопарка
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _fleetIdController.dispose(); // Звільняємо ресурси контролера
    super.dispose();
  }

  // Завантажити збережений ID автопарка
  Future<void> _loadFleetId() async {
    final fleetId = await _apiConfigService.getFleetId();
    setState(() {
      _fleetIdController.text = fleetId.toString();
    });
  }

  // Завантажити збережений URL при ініціалізації
  Future<void> _loadSavedUrl() async {
    final baseUrl = await _apiConfigService.getBaseUrl();

    // Спочатку спробуємо відновити збережену опцію URL
    final savedOption = await _apiConfigService.getSavedUrlOption();

    // Завантажуємо збережений сценарій використання
    final savedScenario = await _apiConfigService.getSavedUsageScenario();

    setState(() {
      _baseUrlController.text = baseUrl;

      if (savedOption != null) {
        // Якщо є збережена опція, використовуємо її
        _selectedOption = UrlOption.values.firstWhere(
          (option) => option.toString() == savedOption,
          orElse: () => UrlOption.ourPublic,
        );
      } else if (_urlOptions.containsValue(baseUrl)) {
        // Інакше визначаємо опцію на основі URL
        _selectedOption = _urlOptions.entries.firstWhere((entry) => entry.value == baseUrl).key;
      } else {
        _selectedOption = UrlOption.custom;
      }

      // Встановлюємо збережений сценарій використання, або за замовчуванням allFleets
      if (savedScenario != null) {
        _selectedScenario = UsageScenario.values.firstWhere(
          (scenario) => scenario.toString() == savedScenario,
          orElse: () => UsageScenario.allFleets,
        );
      }
    });
  }

  // Зберегти URL та налаштування
  Future<void> _saveUrl() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiConfigService.setBaseUrl(_baseUrlController.text.trim());
      // Зберігаємо вибрану опцію URL
      await _apiConfigService.saveUrlOption(_selectedOption.toString());
      // Зберігаємо вибраний сценарій використання
      await _apiConfigService.saveUsageScenario(_selectedScenario.toString());
      // Зберігаємо ID автопарка
      final fleetId = int.tryParse(_fleetIdController.text) ?? 10;
      await _apiConfigService.setFleetId(fleetId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Налаштування збережено!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: ${e.toString()}')),
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

  // Побудова Widget для опції URL
  Widget _buildOptionTile(UrlOption option, String title) {
    return RadioListTile<UrlOption>(
      title: Text(title),
      value: option,
      groupValue: _selectedOption,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedOption = value;

          // Якщо вибрано не Custom, оновити поле введення з відповідним URL
          if (value != UrlOption.custom) {
            _baseUrlController.text = _urlOptions[value]!;
          }
        });
      },
    );
  }

  // Побудова Widget для сценарію використання
  Widget _buildScenarioTile(UsageScenario scenario, String title) {
    return RadioListTile<UsageScenario>(
      title: Text(title),
      subtitle: Text(scenario == UsageScenario.allFleets
          ? 'Користувач бачить всі доступні автопарки'
          : 'Додаток прив\'язаний до "Автопарку 1"'),
      value: scenario,
      groupValue: _selectedScenario,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedScenario = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Секретний екран'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '⚠️ Увага! Цей екран містить налаштування розробника. '
                    'Змінюйте їх, тільки якщо ви знаєте, що робите.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // URL input field
              TextField(
                controller: _baseUrlController,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'Введіть URL API',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Якщо користувач змінив текст вручну, змінюємо опцію на "Custom"
                  if (_urlOptions.values.contains(value)) {
                    setState(() {
                      _selectedOption = _urlOptions.entries.firstWhere((entry) => entry.value == value).key;
                    });
                  } else {
                    setState(() {
                      _selectedOption = UrlOption.custom;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Опції з радіо-кнопками
              const Text(
                'Виберіть попередньо налаштований URL:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildOptionTile(UrlOption.localhost, 'Localhost'),
              _buildOptionTile(UrlOption.ourPublic, 'Our Public URL'),
              _buildOptionTile(UrlOption.withoutInternet, 'Without Internet'),
              _buildOptionTile(UrlOption.custom, 'Custom'),

              const SizedBox(height: 24),

              // Сценарії використання
              const Text(
                'Виберіть сценарій використання:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildScenarioTile(UsageScenario.allFleets, 'Всі автопарки'),
              _buildScenarioTile(UsageScenario.singleFleet, 'Один автопарк'),

              const SizedBox(height: 24),
              
              // Поле для ID автопарка
              const Text(
                'ID автопарка:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fleetIdController,
                decoration: const InputDecoration(
                  labelText: 'ID автопарка',
                  hintText: '10',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Тільки цифрова клавіатура
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUrl,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Зберегти'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
