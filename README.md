# RentSoft Flutter App

A Flutter application for car rental services built using the Repository pattern and Dio for API communication.

## Features

- Authentication (Login/Registration)
- JWT token management with automatic refresh
- Error handling
- Clean architecture with Repository pattern

## Project Structure

```
lib/
├── core/
│   ├── api/
│   │   └── api_client.dart
│   ├── di/
│   │   └── service_locator.dart
│   ├── models/
│   └── services/
│       └── error_handler.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   └── screens/
│   │       └── auth_screen.dart
│   └── home/
│       └── screens/
│           └── home_screen.dart
└── main.dart
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Make sure your API server is running at `http://localhost`
4. Run the app with `flutter run`

## Dependencies

- dio: For API requests
- flutter_bloc: For state management
- equatable: For value equality
- get_it: For dependency injection
- flutter_secure_storage: For secure token storage
- shared_preferences: For local storage

## API Integration

This app integrates with a RESTful API that provides authentication and car rental services. The API endpoints include:

- `/auth`: Login
- `/auth/register`: Registration
- `/auth/refresh`: Token refresh

## Future Improvements

- Add car listing and booking features
- Implement profile management
- Add offline support
