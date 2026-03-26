import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomvia/data/repositories/mock_trip_repository.dart';
import 'package:nomvia/data/repositories/mock_user_repository.dart';
import 'package:nomvia/domain/repositories/trip_repository.dart';
import 'package:nomvia/domain/repositories/user_repository.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return MockTripRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});
