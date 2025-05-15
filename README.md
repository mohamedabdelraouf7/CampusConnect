# CampusConnect - Flutter Mobile Application
CampusConnect is a comprehensive mobile application designed to help students organize their campus life. The app provides features for managing class schedules, study groups, campus events, and announcements in one convenient platform.

## Features
- Home Dashboard : View upcoming classes, events, and study groups at a glance
- Class Schedule : Manage your academic timetable with detailed class information
- Study Groups : Create and join study groups for collaborative learning
- Campus Events : Stay updated on academic, sports, club, and social events
- Announcements : Receive important campus notifications categorized by type
- Dark Mode Support : Toggle between light and dark themes for comfortable viewing
## Project Structure
The project follows a structured organization:
lib/
├── main.dart                  # Application entry point
├── firebase_options.dart      # Firebase configuration
├── models/                    # Data models
├── screens/                   # UI screens
├── services/                  # Business logic services
├── utils/                     # Utility functions and helpers
└── widgets/                   # Reusable UI components
### Key Components
- Models : Define data structures for classes, events, study groups, etc.
- Screens : Implement the user interface for different app sections
- Widgets : Provide reusable UI components like cards and navigation bars
- Utils : Include theme definitions and database helpers
- Services : Handle notifications and data synchronization
## Theme Customization
The app uses a consistent green color scheme based on the CampusConnect logo:

- Primary Green: #4D8C40
- Secondary Green: #6AAC5F
- Light Green: #E8F5E9
Both light and dark themes are supported, with appropriate contrast and readability considerations.

## Dependencies
The application relies on several Flutter packages:

- flutter/material.dart : Core UI components
- shared_preferences : Local storage for user preferences
- firebase_core : Firebase integration
- table_calendar : Calendar widget for scheduling
- intl : Internationalization and date formatting
## Getting Started
1. Ensure you have Flutter installed on your development machine
2. Clone the repository
3. Run flutter pub get to install dependencies
4. Connect a device or start an emulator
5. Run flutter run to launch the application
## Testing
The project includes integration tests to verify core functionality:

- Navigation between screens
- User interactions with the bottom navigation bar
- Form submissions and data persistence
Run tests with: flutter test integration_test

## Contributing
Contributions to CampusConnect are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request
## License
This project is licensed under the MIT License - see the LICENSE file for details.