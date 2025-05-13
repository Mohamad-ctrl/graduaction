# Remote Item Inspection and Delivery Service for Long-Distance Purchases

This repository contains the source code for the "Remote Item Inspection and Delivery Service for Long-Distance Purchases" mobile application, a final year project designed to facilitate remote item inspection and secure delivery for long-distance online purchases. The application aims to bridge the trust gap between buyers and sellers by providing a platform where trusted agents can inspect items on behalf of buyers before purchase and delivery.

For a comprehensive understanding of the project, including its aims, objectives, design, implementation details, and analysis, please refer to the full project report located in the `/latex_report` directory (once compiled to PDF).

## Overview

In the ever-expanding world of e-commerce, purchasing items from distant sellers often comes with uncertainty regarding the item's actual condition and authenticity. "Remote Item Inspection and Delivery Service for Long-Distance Purchases" addresses this by offering a two-pronged service:

1.  **Remote Item Inspection:** Users can request a verified agent to inspect an item at the seller's location. The agent provides a detailed report, including images and comments, on the item's condition.
2.  **Secure Delivery:** Once an item is inspected and approved (or for standalone delivery requests), users can arrange for secure delivery of the item to their desired address.

The application features separate interfaces for regular users and administrators, ensuring a tailored experience for different roles.

## Features

### User-Facing Application

*   **Authentication:** Secure user registration and login (email/password).
*   **Profile Management:** View and update user profile information (username, phone, profile picture).
*   **Account Management:** Manage saved addresses, payment methods (conceptual), and change passwords.
*   **Inspection Requests:**
    *   Create new inspection requests with item details, location, seller contact, and images.
    *   View and track the status of existing inspection requests.
    *   Receive and view detailed inspection reports from agents.
*   **Delivery Requests:**
    *   Create new delivery requests (standalone or linked to an inspection).
    *   Specify pickup and delivery locations, item details, and preferred dates.
    *   View and track the status of delivery requests.
*   **Order History:** Access a consolidated view of all past and current inspection and delivery orders.
*   **Intuitive Navigation:** Bottom navigation bar for easy access to Home, Orders, and Profile sections.

### Admin Panel

*   **Admin Authentication:** Secure login for administrators.
*   **Dashboard:** Overview of system activity, including pending requests and active agents.
*   **Agent Management:**
    *   View, add, edit, and manage agent profiles (inspectors and delivery personnel).
    *   Activate/deactivate agents.
    *   View agent ratings and completed jobs (conceptual).
    *   (Includes a utility to create mock agents for testing).
*   **Inspection Request Management:**
    *   View all inspection requests in the system.
    *   Filter requests by status.
    *   Assign pending inspection requests to available agents.
    *   View inspection reports submitted by agents.
*   **Delivery Request Management:**
    *   View all delivery requests.
    *   Filter requests by status.
    *   Assign pending delivery requests to available agents.
    *   Add tracking numbers to deliveries.
*   **Map View:** (Conceptual) A map-based interface to visualize active agents or ongoing tasks.
*   **Admin Navigation:** Dedicated drawer for navigating admin sections.

## Technology Stack

*   **Frontend (Mobile App):** Flutter (Cross-platform UI toolkit)
*   **Backend Services:**
    *   **Firebase Authentication:** For user and admin authentication.
    *   **Cloud Firestore (Firebase):** NoSQL database for storing user data, agent profiles, inspection requests, delivery requests, and reports.
    *   **Supabase Storage:** For storing images related to inspection requests and reports.
*   **State Management (Flutter):** Provider
*   **Routing (Flutter):** Custom AppRoutes
*   **Programming Language:** Dart

## Project Structure

The Flutter project (`Tproj` directory) follows a standard feature-first or layer-first structure:

*   `Tproj/lib/main.dart`: Main entry point of the application.
*   `Tproj/lib/app_routes.dart`: Defines application routes and navigation.
*   `Tproj/lib/models/`: Contains data models for users, agents, requests, etc.
*   `Tproj/lib/services/`: Houses business logic and interaction with backend services (e.g., `auth_service.dart`, `agent_service.dart`, `inspection_service.dart`, `delivery_service.dart`, `supabase_storage_service.dart`).
*   `Tproj/lib/screens/`: Contains UI code for different application screens, organized into subdirectories for `auth`, `user` (home, profile, orders, inspections, deliveries, account), and `admin`.
*   `Tproj/lib/widgets/`: Contains reusable UI components (e.g., `custom_app_bar.dart`, `bottom_nav_bar.dart`, `admin_drawer.dart`).
*   `Tproj/lib/providers/`: Contains state management providers.
*   `Tproj/lib/utils/`: Utility functions and constants.
*   `Tproj/pubspec.yaml`: Defines project dependencies and metadata.

## Setup and Installation

To run this application locally, you will need to have Flutter installed and configured, along with access to Firebase and Supabase projects.

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Mohamad-ctrl/graduaction.git
    cd graduaction/Tproj
    ```

2.  **Flutter Setup:**
    *   Ensure you have Flutter SDK installed. Refer to the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).
    *   Verify your Flutter setup:
        ```bash
        flutter doctor
        ```

3.  **Firebase Setup:**
    *   Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/).
    *   Add an Android and/or iOS app to your Firebase project.
    *   Follow the instructions to add the Firebase configuration file (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) to your Flutter project (`Tproj/android/app/` and `Tproj/ios/Runner/` respectively).
    *   Enable **Authentication** (Email/Password sign-in method).
    *   Set up **Cloud Firestore** database. You will need to define security rules appropriate for the application.

4.  **Supabase Setup:**
    *   Create a new Supabase project at [https://app.supabase.io/](https://app.supabase.io/).
    *   In your Supabase project, navigate to **Storage** and create a new bucket (e.g., `inspection-images`). Note the bucket name.
    *   Set up appropriate storage policies for access control (e.g., allowing authenticated users to upload to specific paths).
    *   Obtain your Supabase **Project URL** and **anon public key** from Project Settings > API.
    *   You will need to configure these credentials within the Flutter application, typically in a configuration file or directly in `supabase_storage_service.dart` (ensure not to commit sensitive keys directly to public repositories in a production scenario; use environment variables or a gitignored config file).
        *   Update `SupabaseStorageService` in `Tproj/lib/services/supabase_storage_service.dart` with your Supabase URL and anon key.

5.  **Install Dependencies:**
    Navigate to the `Tproj` directory and run:
    ```bash
    flutter pub get
    ```

6.  **Run the Application:**
    Connect a device or start an emulator/simulator and run:
    ```bash
    flutter run
    ```

