import 'package:equatable/equatable.dart';
import 'package:nomvia/domain/entities/agency.dart';
import 'package:nomvia/domain/entities/user.dart';

class Trip extends Equatable {
  final String id;
  final String title;
  final String description; // Itinerary summary
  final double price;
  final int durationDays;
  final DateTime departureDate;
  final String pickupLocation;
  final int totalSeats;
  final int availableSeats;
  final Agency agency;
  final List<String> imageUrls;
  final List<String> inclusions;
  final String cancellationPolicy;
  final int friendsBookedCount; // Social signal
  final List<User> bookedUsers; // For "People Going"
  final String type;

  const Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.departureDate,
    required this.pickupLocation,
    required this.totalSeats,
    required this.availableSeats,
    required this.agency,
    required this.imageUrls,
    required this.inclusions,
    required this.cancellationPolicy,
    required this.friendsBookedCount,
    required this.type,
    this.bookedUsers = const [],
  });

  Trip copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    int? durationDays,
    DateTime? departureDate,
    String? pickupLocation,
    int? totalSeats,
    int? availableSeats,
    Agency? agency,
    List<String>? imageUrls,
    List<String>? inclusions,
    String? cancellationPolicy,
    int? friendsBookedCount,
    List<User>? bookedUsers,
    String? type,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      departureDate: departureDate ?? this.departureDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      agency: agency ?? this.agency,
      imageUrls: imageUrls ?? this.imageUrls,
      inclusions: inclusions ?? this.inclusions,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      friendsBookedCount: friendsBookedCount ?? this.friendsBookedCount,
      bookedUsers: bookedUsers ?? this.bookedUsers,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        durationDays,
        departureDate,
        pickupLocation,
        totalSeats,
        availableSeats,
        agency,
        imageUrls,
        inclusions,
        cancellationPolicy,
        friendsBookedCount,
        type,
        // bookedUsers intentionally omitted to prevent stack overflow
      ];
}
