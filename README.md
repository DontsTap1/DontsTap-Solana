# DontStap (ARCryptoApp)

DontStap is an augmented reality (AR) cryptocurrency-themed mobile application allowing users to collect virtual coins in their real environment, create accounts, and manage their collected coins. The app combines AR technology with gamification elements to create an engaging coin collection experience.

## Architecture Overview

### MVVM Architecture

The application follows the Model-View-ViewModel (MVVM) architectural pattern:

- **Models**: Data structures representing entities like User, Coin, and Promocode.
- **Views**: SwiftUI views implementing the user interface.
- **ViewModels**: Intermediate layer handling business logic and state management.

Each screen or major component has its dedicated ViewModel that manages the state, handles user interactions, and communicates with the various service providers.

### Dependency Injection

Dependency injection is implemented using Swinject for better testability and modular design:

- The app uses a custom `@Inject` property wrapper to simplify service injection.
- `AppAssembler` manages dependency registration and resolution.
- Services are registered through the `ServiceAssembly` class.

## Core Features

### Augmented Reality Experience

DontStap leverages Apple's ARKit and RealityKit frameworks to create an immersive coin collection experience:

- **Plane Detection**: The app identifies horizontal surfaces in the user's environment to place coins realistically.
- **Coin Placement**: Virtual coins are distributed strategically in the user's physical space.
- **Real-time Interaction**: Users can collect coins by tapping on them in AR view.
- **Visual Effects**: Custom animations and effects enhance the coin collection experience.
- **Spatial Audio**: Sound effects are played relative to coin positions for an immersive experience.
- **Performance Optimization**: The AR experience is optimized for smooth performance across supported devices.

### Coin Entity Design

The virtual coins in DontStap were created using Reality Composer on iPad, providing a streamlined 3D design workflow:

- **Design Process**:
  - Created using Reality Composer's intuitive interface on iPad
  - Leveraged built-in 3D modeling tools for coin geometry
  - Added animations for collection effects

- **Features**:
  - Collision detection for user interaction

The coin entities are loaded and managed by the `ARViewModel`, which handles their placement, interaction, and collection in the AR environment.


The AR implementation uses:
- `ARContainerView` as a SwiftUI wrapper for the AR experience
- `ARViewModel` to manage AR session state and user interactions
- Real-time environment tracking to update coin placements as the user moves

### User Authentication

- **Sign in with Apple**: Leverages the `AuthenticationServices` framework to provide secure authentication.
- Flow:
  1. User initiates sign-in via the Apple authentication UI.
  2. Upon successful authentication, user data is persisted both locally and in Firebase.
  3. First-time users are directed to complete their profile by adding a nickname and optional photo.

### User Account Management

- Profile management: Users can update their profile photos and view their collected coins.
- Secure token storage using KeychainStore.
- Support for both authenticated users and guest mode.

## Data Management

### Firebase Integration

The app uses Firebase for backend services:

- **Firebase Realtime Database**: Stores user information, collected coins, and promocodes.
- **Firebase Storage**: Handles user profile images.
- **Firebase Authentication**: Manages user authentication states.
- **Firebase AppCheck**: Provides an additional security layer.

### Database Provider

The `DatabaseProvider` protocol defines methods for data persistence and retrieval:

- User data management (create, read, update)
- Photo storage and retrieval
- Coin tracking
- Promocode validation and management

## Reactive Programming

The application leverages the Combine framework for reactive programming:

- Asynchronous operations like network requests and database operations return publishers.
- ViewModels subscribe to data streams to update the UI based on state changes.
- User interactions trigger events that flow through the system.

## Security

- Secure local storage using Keychain for sensitive data like authentication tokens.
- Firebase AppCheck integration to prevent unauthorized API access.
- Sign in with Apple for secure authentication.

## Project Structure

- **Services**: Core service providers (Authentication, UserSession, etc.)
- **Views**: UI components organized by feature
- **Foundation**: Utility classes, extensions, and helpers
- **Models**: Data models and entities

## Getting Started

1. Clone the repository
2. Install dependencies
3. Configure Firebase (add your GoogleService-Info.plist)
4. Enable Sign in with Apple in your Apple Developer account
5. Build and run the project

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- Device with ARKit support for full functionality

## Dependencies

- Firebase iOS SDK (Auth, Realtime Database, Storage, Firestore, AppCheck)
- Swinject for dependency injection
- SwiftUI for the UI layer
- ARKit and RealityKit for augmented reality features 

### FUTURE Blockchain Integration

DontStap is currently developing Solana blockchain integration for enhanced security and transparency:

- **Solana Storage**: A blockchain-based storage solution is being developed in the `solana_storage` directory.
- **Smart Contracts**: Custom Solana programs for managing coin ownership and transactions.
- **Decentralized Storage**: Future plans to store critical user data on-chain.

For more details about the Solana integration, please refer to the README in the `solana_storage` directory.