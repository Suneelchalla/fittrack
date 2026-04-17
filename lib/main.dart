import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/utils/notification_service.dart';
import 'data/models/user_profile.dart';
import 'data/models/activity_log.dart';
import 'data/models/water_log.dart';
import 'data/models/meal_entry.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ActivityLogAdapter());
  Hive.registerAdapter(WaterLogAdapter());
  Hive.registerAdapter(MealEntryAdapter());

  // Open Hive boxes
  await Hive.openBox<Map>('user_profile');
  await Hive.openBox<Map>('activity_logs');
  await Hive.openBox<Map>('water_logs');
  await Hive.openBox<Map>('meal_entries');

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: FitTrackApp(),
    ),
  );
}
