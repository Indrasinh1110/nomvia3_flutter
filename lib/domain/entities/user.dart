import 'package:equatable/equatable.dart';
import 'package:nomvia/domain/entities/trip.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String profileImageUrl;
  final String travellerType;
  final int tripsDoneCount;
  final int friendsCount;
  final List<Trip> upcomingTrips;
  final List<Trip> completedTrips;
  final List<Trip> savedTrips;
  final List<User> friends; // Added friends list

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImageUrl,
    required this.travellerType,
    required this.tripsDoneCount,
    required this.friendsCount,
    this.upcomingTrips = const [],
    this.completedTrips = const [],
    this.savedTrips = const [],
    this.friends = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        bio,
        profileImageUrl,
        travellerType,
        tripsDoneCount,
        friendsCount,
        // removing lists to prevent stack overflow
      ];
}
