import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) { _load(); }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>('user_profile');
    final data = box.get('profile');
    if (data != null) {
      state = UserProfile.fromMap(Map<String, dynamic>.from(data));
    }
  }

  Future<void> save(UserProfile profile) async {
    final box = await Hive.openBox<Map>('user_profile');
    await box.put('profile', profile.toMap());
    state = profile;
  }

  Future<void> update(UserProfile profile) async => save(profile);

  Future<void> reset() async {
    final box = await Hive.openBox<Map>('user_profile');
    await box.clear();
    state = null;
  }
}

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>(
        (_) => UserProfileNotifier());
