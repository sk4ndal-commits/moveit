import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'data/datasources/database_helper.dart';
import 'data/repositories/activity_repository_impl.dart';
import 'data/repositories/journal_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/activity_repository.dart';
import 'domain/repositories/journal_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'presentation/providers/activity_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/activities_screen.dart';
import 'presentation/screens/journal_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database helper
  final databaseHelper = DatabaseHelper();

  // Initialize repositories
  final userRepository = UserRepositoryImpl(databaseHelper);
  final activityRepository = ActivityRepositoryImpl(databaseHelper);
  final journalRepository = JournalRepositoryImpl(databaseHelper);

  runApp(MyApp(
    userRepository: userRepository,
    activityRepository: activityRepository,
    journalRepository: journalRepository,
  ));
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  final ActivityRepository activityRepository;
  final JournalRepository journalRepository;

  const MyApp({
    super.key,
    required this.userRepository,
    required this.activityRepository,
    required this.journalRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(activityRepository, userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => JournalProvider(journalRepository),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blue[700],
            surface: Colors.blue[50],
            background: Colors.white,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.blue,
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Initialize user data when app starts
  @override
  void initState() {
    super.initState();
    // Initialize user
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.initUser().then((_) {
        if (userProvider.currentUser != null) {
          // Set user ID in other providers
          final activityProvider = Provider.of<ActivityProvider>(context, listen: false);
          final journalProvider = Provider.of<JournalProvider>(context, listen: false);

          activityProvider.setUserId(userProvider.currentUser!.id);
          journalProvider.setUserId(userProvider.currentUser!.id);
        }
      });
    });
  }

  // List of screens to display
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ActivitiesScreen(),
    const JournalScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppConstants.dashboardLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: AppConstants.activitiesLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: AppConstants.journalLabel,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
