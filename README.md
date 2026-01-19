# Baladi - Daily Needs Delivery App

A multi-role mobile application for daily needs delivery in small communities, built with Flutter using **MVVM + Clean Architecture**.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with strict layer separation:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Widgets   │  │  ViewModels │  │   UI State Models   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌─────────┐  │
│  │  Entities │  │ Use Cases │  │  Services │  │  Rules  │  │
│  └───────────┘  └───────────┘  └───────────┘  └─────────┘  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Repository Interfaces                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │  Repository Impls   │  │      Data Sources           │  │
│  └─────────────────────┘  │  ┌─────────┐  ┌─────────┐  │  │
│  ┌─────────────────────┐  │  │  Local  │  │ Remote  │  │  │
│  │     DTOs/Mappers    │  │  └─────────┘  └─────────┘  │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                             │
│  ┌─────────┐  ┌─────────┐  ┌───────────┐  ┌─────────────┐  │
│  │ Errors  │  │ Result  │  │ Utilities │  │     DI      │  │
│  └─────────┘  └─────────┘  └───────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── baladi.dart                 # Main barrel file
├── main.dart                   # App entry point
├── core/                       # Core utilities & base classes
│   ├── core.dart               # Core barrel file
│   ├── config/                 # Environment configuration
│   ├── di/                     # Dependency injection
│   ├── error/                  # Exceptions & failures
│   ├── result/                 # Result pattern (Success/Failure)
│   ├── usecase/                # Base use case interface
│   └── utils/                  # Validators, extensions
├── domain/                     # Business logic layer
│   ├── domain.dart             # Domain barrel file
│   ├── entities/               # Domain entities
│   ├── enums/                  # Domain enums
│   ├── repositories/           # Repository interfaces
│   ├── rules/                  # Business rules (pure functions)
│   ├── services/               # Domain services
│   └── usecases/               # Use cases
├── data/                       # Data access layer
│   ├── data.dart               # Data barrel file
│   ├── datasources/            # Local & remote data sources
│   │   ├── local/              # SharedPreferences, Hive
│   │   └── remote/             # Supabase API calls
│   ├── dto/                    # Data Transfer Objects
│   └── repositories/           # Repository implementations
└── presentation/               # UI layer
    ├── presentation.dart       # Presentation barrel file
    ├── base/                   # Base ViewModel
    ├── state/                  # UI state models
    └── viewmodels/             # Feature ViewModels
```

## 🎯 User Roles

| Role | Authentication | Features |
|------|---------------|----------|
| **Customer** | Mobile + 4-digit PIN | Browse, Order, Loyalty Points, Referrals |
| **Shop** | Username/Password | Products, Orders, Settlements, Ads |
| **Delivery** | Username/Password | Pickups, Deliveries, Cash Collection |
| **Admin** | Username/Password | Full Control, Settlements, Disputes |

## 💰 Key Business Rules

### Points System
- **Earn**: 1 point per 100 EGP spent
- **Referral**: 2 points per first order from referred user
- **Redeem**: 1 point = 1 EGP discount
- **Critical**: Points discount deducted from **Admin commission only**

### Weekly Settlement
- **Period**: Saturday 00:00 → Friday 23:59 (Cairo time)
- **Calculation**: Orders - Commission - Points Discount - Ads Cost

### Order Lifecycle
```
Pending → Accepted → Preparing → PickedUp → ShopPaid → Completed
    ↓         ↓          ↓
Cancelled  Cancelled  Cancelled
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/baladi.git
cd baladi

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Configuration

Initialize the app with the appropriate environment:

```dart
import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initDependencies(environment: Environment.dev);
  
  runApp(const BaladiApp());
}
```

## 📦 Dependencies

### Core Dependencies
- `provider` - State management for MVVM
- `supabase_flutter` - Backend & database
- `shared_preferences` - Simple local storage
- `hive` - NoSQL local database
- `flutter_secure_storage` - Secure storage for tokens

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_messaging` - Push notifications

### Utilities
- `equatable` - Value equality
- `uuid` - Unique ID generation
- `intl` - Internationalization

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📝 Architecture Guidelines

### 1. Business Logic in Domain Layer
All business calculations go in `domain/rules/` or `domain/services/`:
```dart
// ✅ Correct - in domain/rules/points_rules.dart
class PointsRules {
  static int calculatePoints(double amount) => (amount / 100).floor();
}

// ❌ Wrong - in ViewModel
class SomeViewModel {
  int calculatePoints(double amount) => (amount / 100).floor();
}
```

### 2. Use Cases Orchestrate, Don't Calculate
```dart
// ✅ Correct
class PlaceOrder {
  Future<Result<Order>> call(params) async {
    // Orchestrate domain services
    final financials = _orderProcessor.calculateFinancials(...);
    return _orderRepository.createOrder(order);
  }
}
```

### 3. ViewModels Manage UI State Only
```dart
// ✅ Correct
class OrderViewModel extends BaseViewModel {
  Future<void> placeOrder() async {
    setLoading();
    final result = await _placeOrderUseCase(params);
    result.fold(
      onSuccess: (order) => setSuccess(),
      onFailure: (f) => setError(f.message),
    );
  }
}
```

### 4. Result Pattern for Error Handling
```dart
// Use Result<T> for operations that can fail
Future<Result<Order>> getOrder(String id) async {
  try {
    final order = await _remote.getOrder(id);
    return Success(order);
  } catch (e) {
    return Failure(ServerFailure(message: e.toString()));
  }
}
```

## 🎨 UI/UX Design

### Color Palette (Luxurious & Elegant)
- **Primary**: Deep Gold `#D4AF37`
- **Secondary**: Rich Purple `#6B4E71`
- **Accent**: Coral `#FF6B6B`
- **Background**: Soft Cream `#FDF8F3`
- **Surface**: Pure White `#FFFFFF`

### Typography
- **Primary Font**: Poppins (English)
- **Arabic Font**: Cairo (Arabic)

## 📄 License

This project is proprietary software for Baladi delivery service.

## 👥 Contributors

- Architecture & Development Team
