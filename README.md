# CookGenie

An AI-powered iOS application that generates recipes based on available ingredients using SwiftUI and Google Gemini AI.

## How to Run
1. Open **`CookGenie.xcodeproj`** in Xcode.
2. Select a simulator.
3. Press **Cmd + R** to build and run.

## Project Structure
- **`CookGenie/`**: Main iOS application source code (SwiftUI views, ViewModels, and Services).
- **`functions/`**: Firebase Cloud Functions (Node.js) for AI recipe generation and data processing.
- **`CookGenie.xcodeproj`**: Xcode project configuration and build settings.
- **`firebase.json`**: Configuration file for Firebase functions and database.
- **`firestore.rules`**: Security rules for the Cloud Firestore database.
- **`.firebaserc`**: Stores the Firebase project ID and aliases.
- **`package-lock.json`**: Dependency management for the Firebase Cloud Functions.