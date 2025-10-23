# Wassly Food Delivery Platform

## Project Overview

Two separate Flutter applications:

1. **Customer App** - Browse restaurants, place orders, track delivery
2. **Restaurant/Driver App** - Manage products, accept orders, deliver orders

Both apps share the same Firebase backend with 3 user types: customers, restaurants, and drivers.

## Architecture & Technology Stack

### Core Architecture

- **Pattern**: MVVM with Clean Architecture
- **State Management**: flutter_bloc + Cubit
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Functions)
- **Maps**: google_maps_flutter (basic location tracking)

### Project Structure (per app)

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/ (models, repositories)
│   │   ├── domain/ (entities, use cases)
│   │   └── presentation/ (views, cubits)
│   ├── [feature_name]/
│   └── ...
├── shared/
│   └── widgets/
└── main.dart
```

## Firebase Data Models

### Users Collection

```
users/{userId}
├── email: string
├── name: string
├── phone: string
├── userType: enum (customer, restaurant, driver)
├── createdAt: timestamp
└── isActive: boolean
```

### Restaurants Collection

```
restaurants/{restaurantId}
├── ownerId: string (ref to users)
├── name: string
├── description: string
├── imageUrl: string
├── address: string
├── location: GeoPoint
├── isOpen: boolean
└── createdAt: timestamp
```

### Products/Menu Collection

```
products/{productId}
├── restaurantId: string
├── name: string
├── description: string
├── price: number
├── imageUrl: string
├── category: string
├── isAvailable: boolean
└── createdAt: timestamp
```

### Orders Collection

```
orders/{orderId}
├── customerId: string
├── restaurantId: string
├── driverId: string (null initially)
├── items: array
│   ├── productId
│   ├── quantity
│   └── price
├── totalAmount: number
├── status: enum (pending, accepted, preparing, ready, picked_up, delivered, cancelled)
├── deliveryAddress: string
├── deliveryLocation: GeoPoint
├── restaurantLocation: GeoPoint
├── createdAt: timestamp
└── updatedAt: timestamp
```

### Drivers Collection (sub-collection or separate)

```
drivers/{driverId}
├── userId: string (ref to users)
├── currentLocation: GeoPoint
├── isAvailable: boolean
├── isOnline: boolean
└── updatedAt: timestamp
```

## Customer App - Core Features

### 1. Authentication

- Email/password signup and login
- User profile management
- Firebase Auth integration

### 2. Restaurant Browsing

- List all active restaurants with images
- View restaurant details and menu
- Simple search/filter by name

### 3. Cart & Ordering

- Add/remove items to cart
- View cart with total calculation
- Place order with delivery address
- Order confirmation screen

### 4. Order Tracking

- View active orders
- Real-time order status updates
- Basic map view showing restaurant and delivery locations (no live driver tracking)
- Order history

### 5. Profile

- View/edit user details
- View order history
- Logout

## Restaurant/Driver App - Core Features

### 1. Authentication & Role Selection

- Login with email/password
- Role selection: Restaurant Owner or Driver
- Different dashboards based on role

### 2. Restaurant Dashboard

- View incoming orders in real-time
- Accept/reject orders
- Update order status (preparing, ready for pickup)
- Manage products (add, edit, delete, toggle availability)
- Manage restaurant info (name, description, hours)

### 3. Driver Dashboard

- Toggle online/offline status
- View available orders (automatically assigned by system)
- Accept assigned order
- Update order status (picked up, delivered)
- Simple navigation showing restaurant and customer locations
- Basic map showing delivery route

### 4. Automatic Driver Assignment (Cloud Function)

- When order status changes to "ready for pickup"
- Find nearest available online driver
- Assign order to driver
- Notify driver via Firestore listener

## Implementation Phases

### Phase 1: Foundation & Setup

- Create project structure for both apps
- Setup Firebase project and configure both apps
- Install dependencies (flutter_bloc, go_router, firebase packages, google_maps_flutter)
- Create base architecture (core folders, routing, theme)
- Setup Firebase Auth

### Phase 2: Customer App - Core Flow

- Auth screens (login, signup)
- Restaurant list screen
- Restaurant detail & menu screen
- Cart management
- Order placement
- Basic order tracking

### Phase 3: Restaurant App - Restaurant Owner Flow

- Auth & role selection
- Restaurant dashboard
- Order management
- Product management
- Restaurant settings

### Phase 4: Restaurant App - Driver Flow

- Driver dashboard
- Order acceptance
- Delivery tracking with basic map
- Order completion

### Phase 5: Backend Logic & Integration

- Cloud Functions for driver assignment
- Real-time order status synchronization
- Location updates for drivers
- Order state validation

### Phase 6: Polish & Testing

- Error handling
- Loading states
- Empty states
- Form validation
- End-to-end testing

## Dependencies (pubspec.yaml additions)

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Navigation
  go_router: ^14.0.0
  
  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^12.0.0
  
  # UI & Utils
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  intl: ^0.19.0
```

## Development Rules

1. **MVVM Strict Separation**: UI never contains business logic
2. **One Cubit per Feature**: Each screen/module has dedicated Cubit
3. **Immutable States**: All Cubit states are immutable classes using Equatable
4. **GoRouter Only**: All navigation through centralized router.dart
5. **No Direct Firebase Calls in UI**: All Firebase operations in repository layer
6. **Error Handling**: Comprehensive try-catch with user-friendly messages
7. **Loading States**: Always show loading indicators for async operations
8. **Responsive Design**: Support different screen sizes
9. **Code Reusability**: Create shared widgets, extensions, and utilities

## Color Scheme & Design Approach

Since no design is provided, use a modern, clean approach:

- Primary color: Orange/Red (food delivery theme)
- Secondary color: Dark gray/black
- Background: White/light gray
- Cards with subtle shadows
- Rounded corners on buttons and cards
- Material 3 design principles
- Simple, intuitive navigation

## Testing Strategy

- Unit tests for Cubits and repositories
- Widget tests for critical UI components
- Integration tests for complete user flows
- Manual testing for Firebase integration and real-time updates

## Implementation Checklist

- [ ] Phase 1: Setup project structure, Firebase configuration, and dependencies for both apps
- [ ] Phase 1: Create core architecture (folders, routing, theme, base classes)
- [ ] Phase 2: Implement authentication module (login, signup, Firebase Auth integration)
- [ ] Phase 2: Build restaurant browsing and menu viewing in customer app
- [ ] Phase 2: Implement cart management and order placement in customer app
- [ ] Phase 2: Build order tracking with basic map view in customer app
- [ ] Phase 3: Create restaurant owner dashboard and order management
- [ ] Phase 3: Implement product CRUD operations for restaurant owners
- [ ] Phase 4: Build driver dashboard with order acceptance and delivery tracking
- [ ] Phase 5: Create Cloud Function for automatic driver assignment based on proximity
- [ ] Phase 5: Implement real-time order status synchronization across all apps
- [ ] Phase 6: Add error handling, loading states, validation, and comprehensive testing

