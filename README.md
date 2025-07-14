# moveit

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# MoveIt - Sports Activity Tracker

MoveIt is a Flutter-based sports activity tracking app designed to motivate users through gamification and journaling. The app helps users track their sports activities, earn XP, level up, and reflect on their experiences.

## Features

### Dashboard
- View today's scheduled activities
- See total sport hours
- Track XP and level progress
- View activity statistics with charts

### Activities
- Create, edit, and delete sports activities
- Schedule activities for future dates
- Mark activities as completed
- Earn XP based on activity duration

### Journal
- Create journal entries for completed activities
- Record your mood and thoughts about activities
- Earn additional XP for journaling
- Review past journal entries

## Gamification Elements
- Earn XP for completing activities (1 XP per minute)
- Earn 5 XP for each journal entry
- Level up as you accumulate XP
- Track your progress and achievements

## Technical Details

### Architecture
The app follows Clean Architecture principles with three main layers:
- **Domain Layer**: Contains business entities, repository interfaces, and use cases
- **Data Layer**: Implements repositories and data sources
- **Presentation Layer**: Contains UI components and state management

### State Management
- Uses Provider package for state management
- Separate providers for User, Activity, and Journal data

### Local Storage
- SQLite database for persistent storage
- Automatic data loading and synchronization

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Future Enhancements
- Social sharing of activities and achievements
- More detailed statistics and progress tracking
- Customizable activity types and goals
- Notifications and reminders for scheduled activities
# moveit
